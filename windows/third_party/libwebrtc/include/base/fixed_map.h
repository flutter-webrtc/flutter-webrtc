#ifndef BSP_FIXED_MAP_H
#define BSP_FIXED_MAP_H

#include <array>
#include <cassert>
#include <functional>
#include <iostream>
#include <iterator>
#include <ostream>
#include <stdexcept>

#ifdef BSP_FIXED_MAP_THROWS
#include <stdexcept>
#endif

namespace bsp {

namespace fixed_map_detail {
template <class, class Enable = void>
struct is_iterator : std::false_type {};
template <typename T_>
struct is_iterator<
    T_,
    typename std::enable_if<
        std::is_base_of<
            std::input_iterator_tag,
            typename std::iterator_traits<T_>::iterator_category>::value ||
        std::is_same<
            std::output_iterator_tag,
            typename std::iterator_traits<T_>::iterator_category>::value>::type>
    : std::true_type {};
}  // namespace fixed_map_detail

// A simple map of elements stored in a fixed-size array.
// Is essentially a hashmap with open addressing and linear probing.
template <typename Key, typename T, int Capacity, class Hash = std::hash<Key>>
class fixed_map {
  static_assert(Capacity > 0, "Capacity <= 0!");

 public:
  struct slot {
    Key key;
    T value;
    bool valid = false;
  };

  using array_type = std::array<slot, Capacity>;

  using key_type = Key;
  using mapped_type = T;
  using value_type = slot;
  using reference = T&;
  using const_reference = const T&;
  using iterator = typename array_type::iterator;
  using const_iterator = typename array_type::const_iterator;
  using size_type = int;

 public:
  fixed_map(const T& invalid_value = T())
      : size_(0), invalid_value_(invalid_value) {
    clear();
  }

  template <class Container>
  fixed_map(const Container& els) : fixed_map(els.begin(), els.end()) {}

  fixed_map(std::initializer_list<std::pair<Key, T>> list)
      : fixed_map(list.begin(), list.end()) {}

  inline void clear() {
    size_ = 0;
    std::fill(data_.begin(), data_.end(), value_type());
  }

  inline bool empty() const { return size_ == 0; }

  inline size_type size() const { return size_; }

  static constexpr inline size_type max_size() { return Capacity; }

  bool has(const key_type& key) const { return find_index(key) != -1; }

  inline const_reference find(const key_type& key) const {
    auto index = find_index(key);
    if (index != -1)
      return data_[index].value;
    else
      return invalid_value_;
  }

  inline reference find(const key_type& key) {
    auto index = find_index(key);
    if (index != -1)
      return data_[index].value;
    else
      return invalid_value_;
  }

  reference operator[](const key_type& key) { return find(key); }

  const_reference operator[](const key_type& key) const { return find(key); }

  template <typename Key_>
  iterator insert(const Key_& key, const T& value) {
    if (size_ >= max_size()) {
#ifdef BSP_FIXED_MAP_THROWS
      throw std::length_error("fixed_map: trying to insert too many elements");
#endif
    }
    size_type index = hash_to_index(key);
    size_type oindex = index;
    while (data_[index].valid) {
      index = (index + 1) % max_size();
      if (index == oindex) {
        // TODO: This should be unreachable?
        assert(false);
        return begin();
      }
    }
    data_[index].key = key;
    data_[index].value = value;
    data_[index].valid = true;
    size_++;
    return std::next(data_.begin(), index);
  }

  iterator begin() { return data_.begin(); }
  iterator end() { return begin() + max_size(); }

  const_iterator begin() const { return data_.begin(); }
  const_iterator end() const { return begin() + max_size(); }

 protected:
  size_type size_ = 0;
  array_type data_;
  T invalid_value_;

 protected:
  template <typename Iter,
            typename = typename std::enable_if<
                fixed_map_detail::is_iterator<Iter>::value>::type>
  fixed_map(Iter begin_, Iter end_) {
#ifdef BSP_FIXED_MAP_THROWS
    auto size = static_cast<size_type>(std::distance(begin_, end_));
    if (size > max_size())
      throw std::length_error("fixed_map: too many elements");
#endif
    for (auto it = begin_; it != end_; ++it) {
      insert(it->first, it->second);
    }
  }

  static inline std::size_t hash(const key_type& key) { return Hash{}(key); }

  static inline size_type hash_to_index(const key_type& key) {
    return static_cast<size_type>(hash(key) % max_size());
  }

  inline size_type find_index(const key_type& key) const {
    auto start_index = hash_to_index(key);
    auto index = start_index;
    do {
      const auto& slot = data_[index];
      if (slot.valid && slot.key == key) {
        return index;
      }
      index = (index + 1) % max_size();
    } while (index != start_index);
    return -1;
  }

  template <typename Key_, typename T_, int Capacity_, class Hash_>
  friend std::ostream& operator<<(std::ostream&,
                                  const fixed_map<Key_, T_, Capacity_, Hash_>&);
};

template <typename Key_, typename T_, int Capacity_, class Hash_>
inline std::ostream& operator<<(
    std::ostream& out,
    const fixed_map<Key_, T_, Capacity_, Hash_>& map) {
  out << "fixed_map<" << Capacity_ << "> {";
  if (map.empty())
    out << "}";
  else {
    for (auto it = map.data_.begin(); it != map.data_.end(); ++it) {
      const auto& el = *it;
      if (el.valid)
        out << el.key << ": " << el.value;
      else
        out << "_";
      if (std::next(it) != map.data_.end())
        out << ", ";
    }
    out << "}";
  }
  return out;
}

}  // namespace bsp

#endif