import FlutterMacOS
import OpenGL.GL
import OpenGL.GL3

#if SWIFT_PACKAGE
  import Mpv
#endif

public class TextureHW: NSObject, FlutterTexture, ResizableTextureProtocol {
  public typealias UpdateCallback = () -> Void

  private let handle: OpaquePointer
  private let updateCallback: UpdateCallback
  private let pixelFormat: CGLPixelFormatObj
  private let context: CGLContextObj
  private let textureCache: CVOpenGLTextureCache
  private var renderContext: OpaquePointer?
  private var textureContexts = SwappableObjectManager<TextureGLContext>(
    objects: [],
    skipCheckArgs: true
  )

  // #region debug-point mpv-render-lifecycle
  private static func debugReport(
    _ hypothesisId: String,
    _ message: String,
    _ data: [String: Any]
  ) {
    guard let endpoint = ProcessInfo.processInfo.environment["DEBUG_SERVER_URL"],
      let url = URL(string: endpoint)
    else {
      return
    }
    let sessionId = ProcessInfo.processInfo.environment["DEBUG_SESSION_ID"] ?? "macos-mpv-segfault"
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: [
      "sessionId": sessionId,
      "runId": "pre",
      "hypothesisId": hypothesisId,
      "location": "TextureHW.swift",
      "msg": message,
      "data": data,
      "ts": Int(Date().timeIntervalSince1970 * 1000),
    ])
    URLSession.shared.dataTask(with: request).resume()
  }
  // #endregion

  init(
    handle: OpaquePointer,
    updateCallback: @escaping UpdateCallback
  ) {
    self.handle = handle
    self.updateCallback = updateCallback
    self.pixelFormat = OpenGLHelpers.createPixelFormat()
    self.context = OpenGLHelpers.createContext(pixelFormat)
    self.textureCache = OpenGLHelpers.createTextureCache(context, pixelFormat)

    super.init()

    self.initMPV()
  }

  deinit {
    disposePixelBuffer()
    disposeMPV()
    OpenGLHelpers.deleteTextureCache(textureCache)
    OpenGLHelpers.deletePixelFormat(pixelFormat)

    // Deleting the context may cause potential RAM or VRAM memory leaks, as it
    // is used in the `deinit` method of the `TextureGLContext`.
    // Potential fix: use a counter, and delete it only when the counter reaches
    // zero
    OpenGLHelpers.deleteContext(context)
  }

  public func copyPixelBuffer() -> Unmanaged<CVPixelBuffer>? {
    let textureContext = textureContexts.current
    if textureContext == nil {
      return nil
    }

    return Unmanaged.passRetained(textureContext!.pixelBuffer)
  }

  private func initMPV() {
    TextureHW.debugReport("A", "initMPV.begin", [
      "handleNil": false,
      "contextNil": context == nil,
    ])
    CGLSetCurrentContext(context)
    defer {
      OpenGLHelpers.checkError("initMPV")
      CGLSetCurrentContext(nil)
    }

    let api = UnsafeMutableRawPointer(
      mutating: (MPV_RENDER_API_TYPE_OPENGL as NSString).utf8String
    )
    var procAddress = mpv_opengl_init_params(
      get_proc_address: {
        (ctx, name) in
        return TextureHW.getProcAddress(ctx, name)
      },
      get_proc_address_ctx: nil
    )

    var params: [mpv_render_param] = withUnsafeMutableBytes(of: &procAddress) {
      procAddress in
      return [
        mpv_render_param(type: MPV_RENDER_PARAM_API_TYPE, data: api),
        mpv_render_param(
          type: MPV_RENDER_PARAM_OPENGL_INIT_PARAMS,
          data: procAddress.baseAddress.map {
            UnsafeMutableRawPointer($0)
          }
        ),
        mpv_render_param(),
      ]
    }

    let status = mpv_render_context_create(&renderContext, handle, &params)
    TextureHW.debugReport("A", "initMPV.context-created", [
      "status": Int(status),
      "renderContextNil": renderContext == nil,
    ])
    MPVHelpers.checkError(status)

    mpv_render_context_set_update_callback(
      renderContext,
      { (ctx) in
        let that = unsafeBitCast(ctx, to: TextureHW.self)
        DispatchQueue.main.async {
          that.updateCallback()
        }
      },
      UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    )
    TextureHW.debugReport("B", "initMPV.callback-set", [
      "renderContextNil": renderContext == nil,
    ])
  }

  private func disposeMPV() {
    TextureHW.debugReport("B", "disposeMPV.begin", [
      "renderContextNil": renderContext == nil,
    ])
    CGLSetCurrentContext(context)
    defer {
      OpenGLHelpers.checkError("disposeMPV")
      CGLSetCurrentContext(nil)
    }

    mpv_render_context_set_update_callback(renderContext, nil, nil)
    mpv_render_context_free(renderContext)
    renderContext = nil
    TextureHW.debugReport("B", "disposeMPV.end", [
      "renderContextNil": renderContext == nil,
    ])
  }

  public func resize(_ size: CGSize) {
    TextureHW.debugReport("C", "resize", [
      "width": size.width,
      "height": size.height,
    ])
    if size.width == 0 || size.height == 0 {
      return
    }

    NSLog("TextureGL: resize: \(size.width)x\(size.height)")
    createPixelBuffer(size)
  }

  private func createPixelBuffer(_ size: CGSize) {
    disposePixelBuffer()

    textureContexts.reinit(
      objects: [
        TextureGLContext(
          context: context,
          textureCache: textureCache,
          size: size
        ),
        TextureGLContext(
          context: context,
          textureCache: textureCache,
          size: size
        ),
        TextureGLContext(
          context: context,
          textureCache: textureCache,
          size: size
        ),
      ],
      skipCheckArgs: true
    )
  }

  private func disposePixelBuffer() {
    textureContexts.reinit(objects: [], skipCheckArgs: true)
  }

  public func render(_ size: CGSize) {
    let textureContext = textureContexts.nextAvailable()
    TextureHW.debugReport("C", "render.selected-context", [
      "width": size.width,
      "height": size.height,
      "contextNil": textureContext == nil,
      "renderContextNil": renderContext == nil,
    ])
    if textureContext == nil {
      return
    }

    CGLSetCurrentContext(context)
    defer {
      OpenGLHelpers.checkError("render")
      CGLSetCurrentContext(nil)
    }

    glBindFramebuffer(GLenum(GL_FRAMEBUFFER), textureContext!.frameBuffer)
    defer {
      glBindFramebuffer(GLenum(GL_FRAMEBUFFER), 0)
    }

    var fbo = mpv_opengl_fbo(
      fbo: Int32(textureContext!.frameBuffer),
      w: Int32(size.width),
      h: Int32(size.height),
      internal_format: 0
    )
    let fboPtr = withUnsafeMutablePointer(to: &fbo) { $0 }

    var params: [mpv_render_param] = [
      mpv_render_param(type: MPV_RENDER_PARAM_OPENGL_FBO, data: fboPtr),
      mpv_render_param(type: MPV_RENDER_PARAM_INVALID, data: nil),
    ]
    let status = mpv_render_context_render(renderContext, &params)
    TextureHW.debugReport("A", "render.completed", [
      "status": Int(status),
      "renderContextNil": renderContext == nil,
      "frameBuffer": Int(textureContext!.frameBuffer),
    ])

    glFlush()

    textureContexts.pushAsReady(textureContext!)
  }

  static private func getProcAddress(
    _ ctx: UnsafeMutableRawPointer?,
    _ name: UnsafePointer<Int8>?
  ) -> UnsafeMutableRawPointer? {
    let symbol: CFString = CFStringCreateWithCString(
      kCFAllocatorDefault,
      name,
      kCFStringEncodingASCII
    )
    let indentifier = CFBundleGetBundleWithIdentifier(
      "com.apple.opengl" as CFString
    )
    let addr = CFBundleGetFunctionPointerForName(indentifier, symbol)

    if addr == nil {
      NSLog("Cannot get OpenGL function pointer!")
    }
    return addr
  }
}
