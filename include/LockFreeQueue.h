// Hossein Moein
// October 23, 2009
// Copyright (C) 2019-2020 Hossein Moein
// Distributed under the BSD Software License (see file License)

#pragma once

#include <cstdlib>
#include <vector>

// ----------------------------------------------------------------------------

namespace hmq
{

class   LFQEmpty  { public: inline LFQEmpty () noexcept  {   } };

// ----------------------------------------------------------------------------

// NOTE: THIS CLASS MAKES A COUPLE OF IMPORTANT ASSUMPTIONS:
//
//    1) There is only one Consumer and only one Producer threads.
//    2) T values are cheap to copy/move.
//       It maintains a reserved pool of T objects that are
//       never destructed for the life of the queue. New entries are
//       copied to those reserved objects.
//
template<typename T>
class   LockFreeQueue  {

public:

    using value_type = T;
    using size_type = unsigned int;

private:

    struct  Node  {

        value_type  v { };
        Node        *np { nullptr };
        int         cache_index = -1;

        inline Node () noexcept = default;
        inline Node (const value_type &value) noexcept : v (value)  {   }
        inline Node (value_type &&value) noexcept : v (std::move(value))  {   }
    };

    inline Node *get_node_ (const value_type &v) noexcept;
    inline Node *get_node_ (value_type &&v) noexcept;
    inline void release_node_ (Node *n) noexcept;

public:

    LockFreeQueue ();
    LockFreeQueue (LockFreeQueue &&) = default;
    LockFreeQueue &operator = (LockFreeQueue &&) = default;
    LockFreeQueue (const LockFreeQueue &) = delete;
    LockFreeQueue &operator = (const LockFreeQueue &) = delete;
    ~LockFreeQueue ();

    inline void push (const value_type &v) noexcept;
    inline void push (value_type &&v) noexcept;

    inline const value_type &front () const; // throw (LFQEmpty)
    inline value_type &front (); // throw (LFQEmpty)

    // NOTE: The following method returns the data by value.
    //       Therefore it is not as efficient as front().
    //       Use it only if you have to.
    //
    inline value_type pop_front (); // throw (LFQEmpty)

    inline void pop (); // throw (LFQEmpty)

    inline bool empty () const noexcept  { return (slider_ == head_); }

    // This has no practical purpose. It's provided to see what is going on
    // under the hood.
    //
    // NOTE: This is not MT-safe
    //
    inline size_type
	cache_size () const noexcept  { return (node_cache_.size ()); }

    inline size_type new_count() const noexcept  { return (new_count_); }

    // NOTE: This is not MT-safe
    //
    inline void free_cache () noexcept;

private:

    using ReserveVec = std::vector<Node *>;

    // Accessed only by Producer and Destructor
    //
    ReserveVec  node_cache_ { };

    Node        *head_ { nullptr };  // Modified only by Producer
    Node        *tail_ { nullptr };  // Modified only by Producer

    // Anything between tail and slider belogns only to Producer
    //
    Node        *slider_ { nullptr };  // Modified only by Consumer
    size_type   new_count_ { 0 };
};

} // namespace hmq

// ----------------------------------------------------------------------------

#  ifdef DMS_INCLUDE_SOURCE
#    include <LockFreeQueue.tcc>
#  endif // DMS_INCLUDE_SOURCE

// ----------------------------------------------------------------------------

// Local Variables:
// mode:C++
// tab-width:4
// c-basic-offset:4
// End:
