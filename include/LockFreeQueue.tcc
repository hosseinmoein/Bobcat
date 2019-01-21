// Hossein Moein
// October 24, 2009
// Copyright (C) 2019-2020 Hossein Moein
// Distributed under the BSD Software License (see file License)

#include <LockFreeQueue.h>

// ----------------------------------------------------------------------------

namespace hmq
{

template<typename T>
LockFreeQueue<T>::LockFreeQueue ()  {

   // We need a dummy place-holder
   //
    head_ = tail_ = slider_ = get_node_ (value_type ());
}

// ----------------------------------------------------------------------------

template<typename T>
LockFreeQueue<T>::~LockFreeQueue ()  {

    free_reserve ();
    while (tail_)  {
        Node    *tmp = tail_;

        tail_ = tail_->np;
        delete tmp;
    }
}

// ----------------------------------------------------------------------------

template<typename T>
inline void LockFreeQueue<T>::push (const value_type &v) noexcept  {

    head_->np = get_node_ (v);
    head_ = head_->np;

   // Now clean up the already consumed ones
   //
    while (tail_ != slider_)  { // slider_ only moves forward, so we are safe
        release_node_ (tail_);  // There is no deleting
        tail_ = tail_->np;
    }
}

// ----------------------------------------------------------------------------

template<typename T>
inline void LockFreeQueue<T>::push (value_type &&v) noexcept  {

    head_->np = get_node_ (v);
    head_ = head_->np;

   // Now clean up the already consumed ones
   //
    while (tail_ != slider_)  { // slider_ only moves forward, so we are safe
        release_node_ (tail_);  // There is no deleting
        tail_ = tail_->np;
    }
}

// ----------------------------------------------------------------------------

template<typename T>
inline const typename LockFreeQueue<T>::value_type &
LockFreeQueue<T>::front () const  { // throw (LFQEmpty)

    if (slider_ != head_) // head_ only moves forward, so we are safe
        return (slider_->np->v);
    throw LFQEmpty ();
}

// ----------------------------------------------------------------------------

template<typename T>
inline typename LockFreeQueue<T>::value_type
LockFreeQueue<T>::pop_front ()  { // throw (LFQEmpty)

    if (slider_ != head_)  { // head_ only moves forward, so we are safe
        const value_type    &v = slider_->np->v;

        slider_ = slider_->np;
        return (v);
    }
    throw LFQEmpty ();
}

// ----------------------------------------------------------------------------

template<typename T>
inline typename LockFreeQueue<T>::value_type &
LockFreeQueue<T>::front ()  { // throw (LFQEmpty)

    if (slider_ != head_) // head_ only moves forward, so we are safe
        return (slider_->np->v);
    throw LFQEmpty ();
}

// ----------------------------------------------------------------------------

template<typename T>
inline void LockFreeQueue<T>::pop ()  { // throw (LFQEmpty)

    if (slider_ != head_) // head_ only moves forward, so we are safe
        slider_ = slider_->np;
    else
        throw LFQEmpty ();
}

// ----------------------------------------------------------------------------

template<typename T>
inline void LockFreeQueue<T>::free_reserve () noexcept  {

    for (typename ReserveVec::const_iterator citer = reserve_vec_.begin ();
         citer != reserve_vec_.end (); ++citer)
        delete *citer;

    reserve_vec_.clear ();
}

// ----------------------------------------------------------------------------

template<typename T>
inline typename LockFreeQueue<T>::Node *
LockFreeQueue<T>::get_node_ (const value_type &v) noexcept  {

    if (! reserve_vec_.empty ())  {
        Node   *n = reserve_vec_.back ();

        n->v = v;
        n->np = nullptr;
        reserve_vec_.pop_back ();
        return (n);
    }

    ++new_count_;
    return (new Node (v));
}

// ----------------------------------------------------------------------------

template<typename T>
inline typename LockFreeQueue<T>::Node *
LockFreeQueue<T>::get_node_ (value_type &&v) noexcept  {

    if (! reserve_vec_.empty ())  {
        Node   *n = reserve_vec_.back ();

        n->v = std::move(v);
        n->np = nullptr;
        reserve_vec_.pop_back ();
        return (n);
    }

    ++new_count_;
    return (new Node (std::move(v)));
}

// ----------------------------------------------------------------------------

template<typename T>
inline void LockFreeQueue<T>::release_node_ (Node *n) noexcept  {

    reserve_vec_.push_back (n);
}

} // namespace hmq

// ----------------------------------------------------------------------------

// Local Variables:
// mode:C++
// tab-width:4
// c-basic-offset:4
// End:
