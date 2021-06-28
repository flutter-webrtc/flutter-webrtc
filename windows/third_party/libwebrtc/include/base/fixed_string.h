// Customise the behaviour of fixed_string by defining these before including
// it:
// - #define BSP_FIXED_STRING_ZERO_CONTENTS
// - #define BSP_FIXED_STRING_THROWS
// - #define BSP_FIXED_STRING_LOG_ERROR(message) to log errors

#ifndef BSP_FIXED_STRING_H
#define BSP_FIXED_STRING_H

#include <algorithm>
#include <array>
#include <cassert>
#include <cstring>
#include <iterator>
#include <ostream>

namespace bsp {

namespace detail {
template <class InputIt1, class InputIt2>
bool equal(InputIt1 first1, InputIt1 last1, InputIt2 first2, InputIt2) {
  return std::equal(first1, last1, first2);
}
}  // namespace detail

// A fixed-sized string that can store N characters (excluding the
// null-terminator) E.g., fixed_string<4> has a buffer of 5 characters Main use
// is to store small constant strings.
template <int Capacity>
class fixed_string {
  static_assert(Capacity > 0, "Capacity <= 0!");

 public:
  using array_type = std::array<char, Capacity + 1>;
  using iterator = typename array_type::iterator;
  using const_iterator = typename array_type::const_iterator;
  using size_type = int;

 public:
  fixed_string() : size_(0) {
    zero_contents();
    data_[0] = '\0';
  }
  explicit fixed_string(bool truncates) : size_(0), truncates_(truncates) {
    zero_contents();
    data_[0] = '\0';
  }

  fixed_string(const fixed_string&) = default;
  fixed_string(fixed_string&&) = default;
  fixed_string& operator=(const fixed_string& str) = default;
  fixed_string& operator=(fixed_string&& str) = default;

  fixed_string(const char* str, bool truncates = false)
      : fixed_string(str, str + strlen(str), truncates) {}
  template <typename String>
  fixed_string(const String& str, bool truncates = false)
      : fixed_string(std::begin(str), std::end(str), truncates) {}

  fixed_string& operator=(const char* str) {
    return assign(str, str + strlen(str));
  }
  template <typename String>
  fixed_string& operator=(const String& str) {
    using std::begin;
    using std::end;
    return assign(begin(str), end(str));
  }

  std::string str() const { return std::string(begin(), end()); }
  const char* c_str() const { return data_.data(); }

  inline bool truncates() const { return truncates_; }

  void clear() {
    size_ = 0;
    data_[0] = '\0';
  }
  bool empty() const { return size_ == 0; }
  size_type size() const { return size_; }
  static constexpr inline size_type max_size() { return Capacity; }

  void set_size(size_type size) {
    assert(size <= max_size());
    size_ = size;
  }

  char& operator[](size_type index) { return data_[index]; }
  const char& operator[](size_type index) const { return data_[index]; }

  iterator begin() { return data_.begin(); }
  iterator end() { return std::next(begin(), size_); }

  const_iterator begin() const { return data_.begin(); }
  const_iterator end() const { return std::next(begin(), size_); }

  void assign_to(std::string& str) const { str.assign(begin(), end()); }

  template <typename Iter>
  fixed_string& assign(Iter begin_, Iter end_) {
    auto size = static_cast<size_type>(std::distance(begin_, end_));
    if (size > max_size() && !truncates_)
      error("fixed_string is too long!");
    zero_contents();
    size_ = std::min(size, max_size());
    std::copy(begin_, std::next(begin_, size_), data_.begin());
    data_[size_] = '\0';
    size_ = static_cast<size_type>(
        std::distance(begin(), std::find(begin(), end(), '\0')));
    return *this;
  }

 protected:
  std::array<char, Capacity + 1> data_;
  size_type size_ = 0;
  bool truncates_ = false;

 protected:
  // Helper constructor
  template <typename Iter>
  fixed_string(Iter begin_, Iter end_, bool truncates = false)
      : truncates_(truncates) {
    auto size = static_cast<size_type>(std::distance(begin_, end_));
    if (size > max_size() && !truncates_)
      error("fixed_string is too long!");
    zero_contents();
    size_ = std::min(size, max_size());
    std::copy(begin_, std::next(begin_, size_), data_.begin());
    data_[size_] = '\0';
    size_ = static_cast<size_type>(
        std::distance(begin(), std::find(begin(), end(), '\0')));
  }

  inline void zero_contents() {
#ifdef BSP_FIXED_STRING_ZERO_CONTENTS
    data_.fill('\0');
#endif
  }

  void error(const char* message) const {
#ifdef BSP_FIXED_STRING_LOG_ERROR
    BSP_FIXED_STRING_LOG_ERROR(message);
#endif
#ifdef BSP_FIXED_STRING_THROWS
    throw std::runtime_error(message);
#endif
  }

  template <int M>
  friend std::ostream& operator<<(std::ostream& out,
                                  const fixed_string<M>& str);
};

template <int M, int N>
bool operator==(const fixed_string<M>& lhs, const fixed_string<N>& rhs) {
  return lhs.size() == rhs.size() &&
         detail::equal(lhs.begin(), lhs.end(), rhs.begin(), rhs.end());
}

template <int M>
bool operator==(const fixed_string<M>& lhs, const std::string& rhs) {
  return lhs.size() == rhs.size() &&
         detail::equal(lhs.begin(), lhs.end(), rhs.begin(), rhs.end());
}

template <int M>
bool operator==(const fixed_string<M>& lhs, const char* rhs) {
  return lhs.size() == strlen(rhs) &&
         detail::equal(lhs.begin(), lhs.end(), rhs, rhs + lhs.size());
}

template <int M, int N>
bool operator<(const fixed_string<M>& lhs, const fixed_string<N>& rhs) {
  return std::lexicographical_compare(lhs.begin(), lhs.end(), rhs.begin(),
                                      rhs.end());
}

template <int M>
std::ostream& operator<<(std::ostream& out, const fixed_string<M>& str) {
  return out << "fixed_string<" << M << ">\"" << str.c_str() << "\"";
}

}  // namespace bsp

#endif
