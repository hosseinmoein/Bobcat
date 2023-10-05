// Hossein Moein
// August 21, 2007
// Copyright (C) 2019-2020 Hossein Moein
// Distributed under the BSD Software License (see file License)

#include <Bobcat/FixedSizeQueue.h>

// ----------------------------------------------------------------------------

namespace hmq
{

template <typename T>
inline void FixedSizeQueue<T>::
push (const value_type &element, bool wait_if_full)  { // throw (FSQFull) 

    std::unique_lock<std::mutex>    ul(mutex_);

    if (current_size_ >= capacity_)  {
        if (wait_if_full)
            while (current_size_ >= capacity_)
                cvx_.wait (ul);
        else
            throw FSQFull ();
    }

    queue_ [back_pointer_++] = element;

    const size_type circle_affect = back_pointer_ % capacity_;

    if (circle_affect < back_pointer_)
        back_pointer_ = circle_affect;

    if (current_size_++ == 0)   // In case somebody is waiting to pop
        cvx_.notify_all ();

    return;
}

// ----------------------------------------------------------------------------

template <typename T>
inline void FixedSizeQueue<T>::pop ()  { // throw (FSQEmpty)

    const AutoLockable  lock (mutex_);

    if (current_size_ == 0)
        throw FSQEmpty ();

    const size_type circle_affect = ++front_pointer_ % capacity_;

    if (circle_affect < front_pointer_)
        front_pointer_ = circle_affect;

    if (current_size_-- >= capacity_)   // In case somebody is waiting to push
        cvx_.notify_all ();

    return;
}

// ----------------------------------------------------------------------------

template <typename T>
inline const T &FixedSizeQueue<T>::
front (bool wait_on_front) const  { // throw (FSQEmpty)

    std::unique_lock<std::mutex>    ul(mutex_);

    if (current_size_ == 0)  {
        if (wait_on_front)
            while (current_size_ == 0)
                cvx_.wait (ul);
        else
            throw FSQEmpty ();
    }

    return (queue_ [front_pointer_]);
}

// ----------------------------------------------------------------------------

template <typename T>
inline void FixedSizeQueue<T>::
pop_front (value_type &value_out, bool wait_on_front)  { // throw (FSQEmpty)

    std::unique_lock<std::mutex>    ul(mutex_);

    if (current_size_ == 0)  {
        if (wait_on_front)
            while (current_size_ == 0)
                cvx_.wait (ul);
        else
            throw FSQEmpty ();
    }

    value_out = queue_ [front_pointer_++];

    const size_type circle_affect = front_pointer_ % capacity_;

    if (circle_affect < front_pointer_)
        front_pointer_ = circle_affect;

    if (current_size_-- >= capacity_)   // In case somebody is waiting to push
        cvx_.notify_all ();

    return;
}

// ----------------------------------------------------------------------------

template <typename T>
inline T &FixedSizeQueue<T>::
front (bool wait_on_front)  { // throw (FSQEmpty)

    std::unique_lock<std::mutex>    ul(mutex_);

    if (current_size_ == 0)  {
        if (wait_on_front)
            while (current_size_ == 0)
                cvx_.wait (ul);
        else
            throw FSQEmpty ();
    }

    return (queue_ [front_pointer_]);
}

} // namespace hmq

// ----------------------------------------------------------------------------

// Local Variables:
// mode:C++
// tab-width:4
// c-basic-offset:4
// End:
