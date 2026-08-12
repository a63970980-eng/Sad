#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <string>
#include <vector>
#include <windows.h>

// Returns the last error as a string or an empty string if there is no error.
std::string GetLastErrorAsString();

// Returns the command line arguments as a UTF-8 encoded vector.
std::vector<std::string> GetCommandLineArguments();

// Converts a UTF-16 encoded string (from the Windows API) to UTF-8.
std::string Utf8FromUtf16(const wchar_t* utf16_string);

#endif  // RUNNER_UTILS_H_
