#include "utils.h"

#include <iostream>
#include <sstream>

std::vector<std::string> GetCommandLineArguments() {
  // Convert the UTF-16 command line to UTF-8 for the Engine.
  int argc = 0;
  wchar_t** argv = CommandLineToArgvW(GetCommandLineW(), &argc);
  std::vector<std::string> command_line_arguments;

  // Skip the first argument as it's the binary name.
  for (int i = 1; i < argc; i++) {
    command_line_arguments.push_back(Utf8FromUtf16(argv[i]));
  }
  LocalFree(argv);

  return command_line_arguments;
}

std::string Utf8FromUtf16(const wchar_t* utf16_string) {
  if (utf16_string == nullptr) {
    return std::string();
  }
  int utf8_size = WideCharToMultiByte(CP_UTF8, 0, utf16_string, -1, nullptr, 0,
                                      nullptr, nullptr);
  if (utf8_size == 0) {
    return std::string();
  }
  std::string utf8_string(utf8_size - 1, '\0');
  int converted = WideCharToMultiByte(CP_UTF8, 0, utf16_string, -1,
                                      &utf8_string[0], utf8_size, nullptr,
                                      nullptr);
  if (converted == 0) {
    return std::string();
  }
  return utf8_string;
}
