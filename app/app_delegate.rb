class AppDelegate
  def applicationDidFinishLaunching(notification)
    Dir.chdir(NSBundle.mainBundle.resourcePath)
    w = Window.new(WIDTH, HEIGHT, :update_interval => 1000.0 / TARGET_FPS)
    w.caption
    w.show
    NSApp.terminate(self)
  end
end
