// Copyright 2022 Sony Corporation. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

#ifndef COMMAND_OPTIONS_
#define COMMAND_OPTIONS_

#include <iostream>
#include <memory>
#include <sstream>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

namespace commandline {

namespace {
constexpr char kOptionStyleNormal[] = "--";
constexpr char kOptionStyleShort[] = "-";
constexpr char kOptionValueForHelpMessage[] = "=<value>";
}  // namespace

class Exception : public std::exception {
 public:
  Exception(const std::string& msg) : msg_(msg) {}
  ~Exception() throw() {}

  const char* what() const throw() { return msg_.c_str(); }

 private:
  std::string msg_;
};

class CommandOptions {
 public:
  CommandOptions() = default;
  ~CommandOptions() = default;

  void AddWithoutValue(const std::string& name,
                       const std::string& short_name,
                       const std::string& description,
                       bool required) {
    Add<std::string, ReaderString>(name, short_name, description, "",
                                   ReaderString(), required, false);
  }

  void AddInt(const std::string& name,
              const std::string& short_name,
              const std::string& description,
              const int& default_value,
              bool required) {
    Add<int, ReaderInt>(name, short_name, description, default_value,
                        ReaderInt(), required, true);
  }

  void AddDouble(const std::string& name,
              const std::string& short_name,
              const std::string& description,
              const double& default_value,
              bool required) {
    Add<double, ReaderDouble>(name, short_name, description, default_value,
                        ReaderDouble(), required, true);
  }

  void AddString(const std::string& name,
                 const std::string& short_name,
                 const std::string& description,
                 const std::string& default_value,
                 bool required) {
    Add<std::string, ReaderString>(name, short_name, description, default_value,
                                   ReaderString(), required, true);
  }

  template <typename T, typename F>
  void Add(const std::string& name,
           const std::string& short_name,
           const std::string& description,
           const T default_value,
           F reader = F(),
           bool required = true,
           bool required_value = true) {
    if (options_.find(name) != options_.end()) {
      std::cerr << "Already registered option: " << name << std::endl;
      return;
    }

    if (lut_short_options_.find(short_name) != lut_short_options_.end()) {
      std::cerr << short_name << "is already registered" << std::endl;
      return;
    }
    lut_short_options_[short_name] = name;

    options_[name] = std::make_unique<OptionValueReader<T, F>>(
        name, short_name, description, default_value, reader, required,
        required_value);

    // register to show help message.
    registration_order_options_.push_back(options_[name].get());
  }

  bool Exist(const std::string& name) {
    auto itr = options_.find(name);
    return itr != options_.end() && itr->second->HasValue();
  }

  template <typename T>
  const T& GetValue(const std::string& name) {
    auto itr = options_.find(name);
    if (itr == options_.end()) {
      throw Exception("Not found: " + name);
    }

    auto* option_value = dynamic_cast<const OptionValue<T>*>(itr->second.get());
    if (!option_value) {
      throw Exception("Type mismatch: " + name);
    }
    return option_value->GetValue();
  }

  bool Parse(int argc, const char* const* argv) {
    if (argc < 1) {
      errors_.push_back("No options");
      return false;
    }

    command_name_ = argv[0];
    for (auto i = 1; i < argc; i++) {
      const std::string arg(argv[i]);

      // normal options: e.g. --bundle=/data/sample/bundle --fullscreen
      if (arg.length() > 2 &&
          arg.substr(0, 2).compare(kOptionStyleNormal) == 0) {
        const size_t option_value_len = arg.find("=") != std::string::npos
                                            ? (arg.length() - arg.find("="))
                                            : 0;
        const bool has_value = option_value_len != 0;
        std::string option_name =
            arg.substr(2, arg.length() - 2 - option_value_len);

        if (options_.find(option_name) == options_.end()) {
          errors_.push_back("Not found option: " + option_name);
          continue;
        }

        if (!has_value && options_[option_name]->IsRequiredValue()) {
          errors_.push_back(option_name + " requres an option value");
          continue;
        }

        if (has_value && !options_[option_name]->IsRequiredValue()) {
          errors_.push_back(option_name + " doesn't requres an option value");
          continue;
        }

        if (has_value) {
          SetOptionValue(option_name, arg.substr(arg.find("=") + 1));
        } else {
          SetOption(option_name);
        }
      }
      // short options: e.g. -f /foo/file.txt -h 640 -abc
      else if (arg.length() > 1 &&
               arg.substr(0, 1).compare(kOptionStyleShort) == 0) {
        for (size_t j = 1; j < arg.length(); j++) {
          const std::string option_name{argv[i][j]};

          if (lut_short_options_.find(option_name) ==
              lut_short_options_.end()) {
            errors_.push_back("Not found short option: " + option_name);
            break;
          }

          if (j == arg.length() - 1 &&
              options_[lut_short_options_[option_name]]->IsRequiredValue()) {
            if (i == argc - 1) {
              errors_.push_back("Invalid format option: " + option_name);
              break;
            }
            SetOptionValue(lut_short_options_[option_name], argv[++i]);
          } else {
            SetOption(lut_short_options_[option_name]);
          }
        }
      } else {
        errors_.push_back("Invalid format option: " + arg);
      }
    }

    for (size_t i = 0; i < registration_order_options_.size(); i++) {
      if (registration_order_options_[i]->IsRequired() &&
          !registration_order_options_[i]->HasValue()) {
        errors_.push_back(
            std::string(registration_order_options_[i]->GetName()) +
            " option is mandatory.");
      }
    }

    return errors_.size() == 0;
  }

  std::string GetError() { return errors_.size() > 0 ? errors_[0] : ""; }

  std::vector<std::string>& GetErrors() { return errors_; }

  std::string ShowHelp() {
    std::ostringstream ostream;

    ostream << "Usage: " << command_name_ << " ";
    for (size_t i = 0; i < registration_order_options_.size(); i++) {
      if (registration_order_options_[i]->IsRequired()) {
        ostream << registration_order_options_[i]->GetHelpShortMessage() << " ";
      }
    }
    ostream << std::endl;

    ostream << "Global options:" << std::endl;
    size_t max_name_len = 0;
    for (size_t i = 0; i < registration_order_options_.size(); i++) {
      max_name_len = std::max(
          max_name_len, registration_order_options_[i]->GetName().length());
    }

    for (size_t i = 0; i < registration_order_options_.size(); i++) {
      if (!registration_order_options_[i]->GetShortName().empty()) {
        ostream << kOptionStyleShort
                << registration_order_options_[i]->GetShortName() << ", ";
      } else {
        ostream << std::string(4, ' ');
      }

      size_t index_adjust = 0;
      constexpr int kSpacerNum = 10;
      auto need_value = registration_order_options_[i]->IsRequiredValue();
      ostream << kOptionStyleNormal
              << registration_order_options_[i]->GetName();
      if (need_value) {
        ostream << kOptionValueForHelpMessage;
        index_adjust += std::string(kOptionValueForHelpMessage).length();
      }
      ostream << std::string(
          max_name_len + kSpacerNum - index_adjust -
              registration_order_options_[i]->GetName().length(),
          ' ');
      ostream << registration_order_options_[i]->GetDescription() << std::endl;
    }

    return ostream.str();
  }

 private:
  struct ReaderInt {
    int operator()(const std::string& value) { return std::stoi(value); }
  };

  struct ReaderString {
    std::string operator()(const std::string& value) { return value; }
  };

  struct ReaderDouble {
    double operator()(const std::string& value) { return std::stod(value); }
  };

  class Option {
   public:
    Option(const std::string& name,
           const std::string& short_name,
           const std::string& description,
           bool required,
           bool required_value)
        : name_(name),
          short_name_(short_name),
          description_(description),
          is_required_(required),
          is_required_value_(required_value),
          value_set_(false){};
    virtual ~Option() = default;

    const std::string& GetName() const { return name_; };

    const std::string& GetShortName() const { return short_name_; };

    const std::string& GetDescription() const { return description_; };

    const std::string GetHelpShortMessage() const {
      std::string message = kOptionStyleNormal + name_;
      if (is_required_value_) {
        message += kOptionValueForHelpMessage;
      }
      return message;
    }

    bool IsRequired() const { return is_required_; };

    bool IsRequiredValue() const { return is_required_value_; };

    void Set() { value_set_ = true; };

    virtual bool SetValue(const std::string& value) = 0;

    virtual bool HasValue() const = 0;

   protected:
    std::string name_;
    std::string short_name_;
    std::string description_;
    bool is_required_;
    bool is_required_value_;
    bool value_set_;
  };

  template <typename T>
  class OptionValue : public Option {
   public:
    OptionValue(const std::string& name,
                const std::string& short_name,
                const std::string& description,
                const T& default_value,
                bool required,
                bool required_value)
        : Option(name, short_name, description, required, required_value),
          default_value_(default_value),
          value_(default_value){};
    virtual ~OptionValue() = default;

    bool SetValue(const std::string& value) {
      value_ = Read(value);
      value_set_ = true;
      return true;
    }

    bool HasValue() const { return value_set_; }

    const T& GetValue() const { return value_; }

   protected:
    virtual T Read(const std::string& s) = 0;

    T default_value_;
    T value_;
  };

  template <typename T, typename F>
  class OptionValueReader : public OptionValue<T> {
   public:
    OptionValueReader(const std::string& name,
                      const std::string& short_name,
                      const std::string& description,
                      const T default_value,
                      F reader,
                      bool required,
                      bool required_value)
        : OptionValue<T>(name,
                         short_name,
                         description,
                         default_value,
                         required,
                         required_value),
          reader_(reader) {}
    ~OptionValueReader() = default;

   private:
    T Read(const std::string& value) { return reader_(value); }

    F reader_;
  };

  bool SetOption(const std::string& name) {
    auto itr = options_.find(name);
    if (itr == options_.end()) {
      errors_.push_back("Unknown option: " + name);
      return false;
    }

    itr->second->Set();
    return true;
  }

  bool SetOptionValue(const std::string& name, const std::string& value) {
    auto itr = options_.find(name);
    if (itr == options_.end()) {
      errors_.push_back("Unknown option: " + name);
      return false;
    }

    if (!itr->second->SetValue(value)) {
      errors_.push_back("Invalid option value: " + name + " = " + value);
      return false;
    }
    return true;
  }

  std::string command_name_;
  std::unordered_map<std::string, std::unique_ptr<Option>> options_;
  std::unordered_map<std::string, std::string> lut_short_options_;
  std::vector<Option*> registration_order_options_;
  std::vector<std::string> errors_;
};

}  // namespace commandline

#endif  // COMMAND_OPTIONS_
