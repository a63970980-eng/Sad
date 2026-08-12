#ifndef RUNNER_FLUTTER_WINDOW_H_
#define RUNNER_FLUTTER_WINDOW_H_

#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>

#include <memory>

#include "win32_window.h"

class FlutterWindow : public Win32Window {
 public:
  explicit FlutterWindow(const flutter::DartProject& project);
  virtual ~FlutterWindow();

 protected:
  // Win32Window overrides
  bool OnCreate() override;
  void OnDestroy() override;
  LRESULT MessageHandler(HWND hwnd, UINT const message, WPARAM const wparam,
                         LPARAM const lparam) noexcept override;
  PhysicalWindowBounds GetPhysicalWindowBounds() override;

 private:
  // The project used to produce the Flutter embedder's runnable/runnable.
  flutter::DartProject project_;

  // The Flutter view controller
  std::unique_ptr<flutter::FlutterViewController> flutter_controller_;
};

#endif  // RUNNER_FLUTTER_WINDOW_H_
