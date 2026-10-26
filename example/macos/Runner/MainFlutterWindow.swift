import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let windowFrame = self.frame
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)
    VideoProcessorSample.register(
      with: flutterViewController.registrar(forPlugin: "VideoProcessorSample"))

    super.awakeFromNib()
  }
}
