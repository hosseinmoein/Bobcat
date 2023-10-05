// Hossein Moein
// August 21, 2007
// Copyright (C) 2019-2020 Hossein Moein
// Distributed under the BSD Software License (see file License)

#pragma once

#include <cstdlib>
#include <vector>
#include <mutex>
#include <condition_variable>

// ----------------------------------------------------------------------------

namespace hmq
{

class   FSQEmpty  { public: inline FSQEmpty () throw ()  {   } };
class   FSQFull  { public: inline FSQFull () throw ()  {   } };

// ----------------------------------------------------------------------------

// The only reason for this class is to avoid memory fragmentation in
// systems that use the queue with ultra high frequency.
// This queue has a fixed size and therefore does not allocate dynamic memory
// at run time (all elements are pre-allocated in the constructor).
// Because this is a fixed size circular queue, there can be waiting on
// pushing and popping.
//
// NOTE: The destructors for the pre-allocated elements in the queue are
//       never called (well they are called when this object is destructed).
//       Only the assignment operators are called repeatedly in a circular
//       fashion. THIS IS IMPORTANT TO NOTE.
//
template <typename T>
class   FixedSizeQueue  {

private:

    using QueueType = std::vector<T>;
    using AutoLockable = std::lock_guard<std::mutex>;

public:

    using value_type = T;
    using size_type = unsigned int;

    inline explicit FixedSizeQueue (size_type capacity)
        : queue_ (capacity),
          capacity_ (capacity)  {   }
    FixedSizeQueue (FixedSizeQueue &&) = default;
    FixedSizeQueue &operator = (FixedSizeQueue &&) = default;
    FixedSizeQueue () = delete;
    FixedSizeQueue (const FixedSizeQueue &) = delete;
    FixedSizeQueue &operator = (const FixedSizeQueue &) = delete;

    inline void push (const value_type &element,
                      bool wait_if_full = true); // throw (FSQFull);
    inline void pop (); // throw (FSQEmpty);

    inline const value_type &
    front (bool wait_on_front = true) const; // throw (FSQEmpty);
    inline value_type &
    front (bool wait_on_front = true); // throw (FSQEmpty);

    inline void pop_front (value_type &value_out,
                           bool wait_on_front = true); // throw (FSQEmpty);

    inline bool empty () const noexcept  {

        const AutoLockable  lock (mutex_);

        return (current_size_ == 0);
    }

    inline size_type size () const noexcept  {

        const AutoLockable  lock (mutex_);

        return (current_size_);
    }

    inline size_type capacity () const noexcept  { return (capacity_); }

private:

    mutable std::mutex              mutex_ { };
    mutable std::condition_variable cvx_ { };

    QueueType       queue_;
    size_type       current_size_ { 0 };
    size_type       front_pointer_ { 0 };
    size_type       back_pointer_ { 0 };
    const size_type capacity_;
};

} // namespace hmq

// ----------------------------------------------------------------------------

#  ifdef DMS_INCLUDE_SOURCE
#    include <Bobcat/FixedSizeQueue.tcc>
#  endif // DMS_INCLUDE_SOURCE

// ----------------------------------------------------------------------------

// Local Variables:
// mode:C++
// tab-width:4
// c-basic-offset:4
// End:
