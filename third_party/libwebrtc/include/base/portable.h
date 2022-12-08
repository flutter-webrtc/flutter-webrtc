#ifndef INFINISPAN_HOTROD_PORTABLE_H
#define INFINISPAN_HOTROD_PORTABLE_H

#ifdef LIB_WEBRTC_API_EXPORTS
#define LIB_PORTABLE_API __declspec(dllexport)
#elif defined(LIB_WEBRTC_API_DLL)
#define LIB_PORTABLE_API __declspec(dllimport)
#elif !defined(WIN32)
#define LIB_PORTABLE_API __attribute__((visibility("default")))
#else
#define LIB_PORTABLE_API
#endif

#include <cstdlib>
#include <cstring>
#include <map>
#include <string>
#include <vector>

/**
 * This file defines structures that can be passed across shared library/DLL
 * boundary.
 *
 * Besides memory layout, the class must be destroyed in the same library as
 * created. None of these classes is thread-safe. The classes are not optimized
 * for performance.
 */

namespace portable {

#ifdef _MSC_VER
#define strncpy_safe strncpy_s
#else
#ifndef _TRUNCATE
#define _TRUNCATE ((size_t)-1)
#endif  // _TRUNCATE
#endif

#define PORTABLE_STRING_BUF_SIZE 48

class string {
 private:
  char m_buf[PORTABLE_STRING_BUF_SIZE];
  char* m_dynamic;
  size_t m_length;

 public:
  LIB_PORTABLE_API string();
  LIB_PORTABLE_API void init(const char* str, size_t len);
  LIB_PORTABLE_API void destroy();

  inline string(const char* str) { init(str, strlen(str)); }

  inline string(const std::string& str) { init(str.c_str(), str.length()); }

  inline string(const string& o) {
    init(o.m_dynamic == 0 ? o.m_buf : o.m_dynamic, o.m_length);
  }

  inline string& operator=(const string& o) {
    destroy();
    init(o.m_dynamic == 0 ? o.m_buf : o.m_dynamic, o.m_length);
    return *this;
  }

  LIB_PORTABLE_API ~string();

  inline string& operator=(const std::string& str) {
    destroy();
    init(str.c_str(), str.length());
    return *this;
  }

  inline size_t size() { return m_length; }

  inline const char* c_string() const {
    return m_dynamic == 0 ? m_buf : m_dynamic;
  }

  inline std::string std_string() const {
    return std::string(m_dynamic == 0 ? m_buf : m_dynamic, m_length);
  }
};

inline std::string to_std_string(const string& str) {
  return str.std_string();
}

template <typename T>
class identity {
  T operator()(const T& x) { return x; }
};

template <typename T>
class vector {
 protected:
  using raw_type = typename std::aligned_storage<sizeof(T), alignof(T)>::type;

 private:
  T* m_array;
  size_t m_size;

 public:
  class move_ref {
    friend class vector;

   private:
    vector<T>& m_ref;
    move_ref(vector<T>& ref) : m_ref(ref) {}
  };

  vector() : m_array(0), m_size(0) {}
  vector(T* array, size_t s) : m_array(array), m_size(s) {}

  template <typename Iterable>
  vector(const Iterable& v) {
    m_size = v.size();
    if (v.size() == 0) {
      m_array = 0;
    } else {
      m_array = new T[v.size()];
      size_t i = 0;
      for (typename Iterable::const_iterator it = v.begin(); it != v.end();
           ++it) {
        m_array[i++] = *it;
      }
    }
  }

  template <typename Iterable, typename Converter>
  vector(const Iterable& v, Converter convert) {
    m_size = v.size();
    if (v.size() == 0) {
      m_array = 0;
    } else {
      m_array = new T[v.size()];
      size_t i = 0;
      for (typename Iterable::const_iterator it = v.begin(); it != v.end();
           ++it) {
        m_array[i++] = convert(*it);
      }
    }
  }

  vector(const vector<T>& o) {
    m_size = o.m_size;
    if (m_size != 0) {
      m_array = new T[o.m_size];
      for (size_t i = 0; i < o.m_size; ++i) {
        m_array[i] = o.m_array[i];
      }
    }
  }

  ~vector() { destroy_all(); }

  vector<T>& operator=(const vector<T>& o) {
    if (m_size < o.m_size) {
      destroy_all();
      m_array = new T[o.m_size];
    } else if (o.m_size == 0 && m_size != 0) {
      destroy_all();
    }
    m_size = o.m_size;
    for (size_t i = 0; i < o.m_size; ++i) {
      m_array[i] = o.m_array[i];
    }
    return *this;
  }

  vector(move_ref mr) : m_array(mr.m_ref.m_array), m_size(mr.m_ref.m_size) {}
  vector<T>& operator=(move_ref mr) {
    if (m_size != 0) {
      destroy_all();
    }
    m_size = mr.m_ref.m_size;
    m_array = mr.m_ref.m_array;
    mr.m_ref.m_size = 0;
    mr.m_ref.m_array = 0;
    return *this;
  }
  /**
   * Not really safe - can't be used as vector(something).move(),
   * but vector tmp(something); other = tmp.move();
   */
  move_ref move() { return move_ref(*this); }

  std::vector<T> std_vector() const {
    std::vector<T> v;
    v.reserve(m_size);
    for (size_t i = 0; i < m_size; ++i) {
      v.push_back(m_array[i]);
    }
    return v;
  }

  const T* data() const { return m_array; }

  size_t size() const { return m_size; }

  T& operator[](size_t i) { return m_array[i]; }

  const T& operator[](size_t i) const { return m_array[i]; }

  void clear() { destroy_all(); }

 protected:
  void destroy(T* rt) { reinterpret_cast<const T*>(rt)->~T(); }

  void destroy_all() {
    for (size_t i = 0; i < m_size; ++i) {
      destroy(&m_array[i]);
    }
    m_size = 0;
  }
};

template <typename K, typename V>
class pair {
 public:
  K key;
  V value;
};

template <typename K, typename V>
class map {
 private:
  typedef pair<K, V> my_pair;

  vector<my_pair> m_vec;

  /*template<typename K2, typename V2>
  static pair *to_array(const std::map<K2, V2> &m,
      K (*convertKey)(const K2 &),
      V (*convertValue)(const V2 &))
  {
      my_pair *data = new my_pair[m.size()];
      my_pair *dp = data;
      for (std::map<K2, V2>::const_iterator it = m.begin(); it != m.end(); ++it)
  { dp->key = convertKey(it->first); dp->value = convertValue(it->second);
          ++dp;
      }
      return data;
  }*/

  template <typename K2, typename KC, typename V2, typename VC>
  static my_pair* to_array(const std::map<K2, V2>& m,
                           KC convertKey,
                           VC convertValue) {
    my_pair* data = new my_pair[m.size()];
    my_pair* dp = data;
    for (typename std::map<K2, V2>::const_iterator it = m.begin();
         it != m.end(); ++it) {
      dp->key = convertKey(it->first);
      dp->value = convertValue(it->second);
      ++dp;
    }
    return data;
  }

 public:
  class move_ref {
    friend class map;

   private:
    map<K, V>& m_ref;
    move_ref(map<K, V>& ref) : m_ref(ref) {}
  };

  map() {}

  /*    template<typename K2, typename V2> map(const std::map<K2, V2> &m,
          K (*convertKey)(const K2 &) = identity<K>,
          V (*convertValue)(const V2 &) = identity<V>):
          m_vec(to_array(m, convertKey, convertValue), m.size()) {}*/

  map(const std::map<K, V>& m)
      : m_vec(to_array(m, identity<K>(), identity<V>()), m.size()) {}

  template <typename K2, typename KC, typename V2, typename VC>
  map(const std::map<K2, V2>& m,
      KC convertKey = identity<K>(),
      VC convertValue = identity<V>())
      : m_vec(to_array(m, convertKey, convertValue), m.size()) {}

  map(const map<K, V>& o) { m_vec = o.m_vec; }

  map<K, V>& operator=(const map<K, V>& o) {
    m_vec = o.m_vec;
    return *this;
  }

  map(move_ref mr) : m_vec(mr.m_ref.m_vec.move()) {}
  map<K, V>& operator=(move_ref mr) {
    m_vec = mr.m_ref.m_vec.move();
    return *this;
  }
  move_ref move() { return move_ref(*this); }

  std::map<K, V> std_map() const {
    std::map<K, V> m;
    for (size_t i = 0; i < m_vec.size(); ++i) {
      const my_pair* dp = m_vec.data() + i;
      m[dp->key] = dp->value;
    }
    return m;
  }

  template <typename K2, typename KC, typename V2, typename VC>
  std::map<K2, V2> std_map(KC convertKey, VC convertValue) const {
    std::map<K2, V2> m;
    for (size_t i = 0; i < m_vec.size(); ++i) {
      const my_pair* dp = m_vec.data() + i;
      m[convertKey(dp->key)] = convertValue(dp->value);
    }
    return m;
  }

  template <typename K2>
  const my_pair* get(K2 key, int (*cmp)(K2, const K&)) const {
    for (size_t i = 0; i < m_vec.size(); ++i) {
      const my_pair* dp = m_vec.data() + i;
      if (!cmp(key, dp->key))
        return dp;
    }
    return 0;
  }

  const my_pair* data() const { return m_vec.data(); }

  size_t size() const { return m_vec.size(); }
};

/* Invasive reference counting */
template <typename T>
class counting_ptr;

class counted_object {
  template <typename T>
  friend class counting_ptr;

 private:
  int m_counter;

 public:
  counted_object() : m_counter(0) {}
  virtual ~counted_object() {}
};

template <typename T>
class counted_wrapper : public counted_object {
 private:
  T m_object;

 public:
  counted_wrapper(const T& o) : m_object(o) {}
  T& operator()() { return m_object; }
};

template <typename T>
class counting_ptr {
 public:
  typedef void (*destroy)(T*);

 private:
  counted_object* m_ptr;
  destroy m_destroy;

  inline void dec_and_destroy() {
    if (m_ptr != 0 && --(m_ptr->m_counter) == 0) {
      if (m_destroy == 0) {
        delete m_ptr;
      } else {
        m_destroy((T*)m_ptr);
      }
    }
  }

 public:
  counting_ptr() : m_ptr(0), m_destroy(0) {}
  counting_ptr(T* obj, destroy d = 0) : m_ptr(obj), m_destroy(d) {
    counted_object* rc = obj;  // no cast required
    if (rc != 0) {
      rc->m_counter++;
    }
  }
  ~counting_ptr() { dec_and_destroy(); }
  counting_ptr(const counting_ptr& o) : m_ptr(o.m_ptr), m_destroy(o.m_destroy) {
    if (m_ptr != 0) {
      m_ptr->m_counter++;
    }
  }
  counting_ptr& operator=(const counting_ptr& o) {
    dec_and_destroy();
    m_ptr = o.m_ptr;
    m_destroy = o.m_destroy;
    if (m_ptr != 0) {
      m_ptr->m_counter++;
    }
    return *this;
  }
  counting_ptr& operator=(T* rc) { return reset(rc, 0); }
  counting_ptr& reset(T* rc, destroy d) {
    dec_and_destroy();
    m_ptr = rc;
    m_destroy = d;
    if (rc != 0) {
      rc->m_counter++;
    }
    return *this;
  }
  T* get() { return (T*)m_ptr; }
  const T* get() const { return (T*)m_ptr; }
  T* operator->() { return (T*)m_ptr; }
  const T* operator->() const { return (const T*)m_ptr; }
};

template <typename T>
class local_ptr {
 private:
  typedef void (*destroy)(T*);
  T* m_ptr;
  destroy m_destroy;

 public:
  local_ptr() : m_ptr(0), m_destroy(0) {}
  local_ptr(const local_ptr&)
      : m_ptr(0), m_destroy(0) {}  // copying does not persist value
  local_ptr& operator=(const local_ptr&) { return *this; }
  ~local_ptr() {
    if (m_ptr)
      m_destroy(m_ptr);
  }
  const T* get() const { return m_ptr; }
  T* get() { return m_ptr; }
  void set(T* ptr, void (*dtor)(T*)) {
    if (m_ptr)
      m_destroy(m_ptr);
    m_ptr = ptr;
    m_destroy = dtor;
  }
};

}  // namespace portable

#endif  // INFINISPAN_HOTROD_PORTABLE_H