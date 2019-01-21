// Hossein Moein
// August 21, 2007

#include <cstdio>
#include <ctime>
#include <iostream>
#include <thread>

#include <FixedSizeQueue.h>

using namespace hmq;

//-----------------------------------------------------------------------------

void *pusher ();
void *popper ();
void *counter ();

FixedSizeQueue<int>    Q (10);
static const int       MAX_COUNT = 100000;

//-----------------------------------------------------------------------------

struct    Base  {
	int  i_;
	Base (int i) : i_ (i)  {   }
};

struct   left : public virtual Base  {
	left () : Base (1)  {  }
};

struct   right : public virtual Base  {
	right () : Base (2)  {  }
};

struct   bottom : public left, public right  {

	bottom () : Base (3)  {  }
};

int main (int argc, char *argv [])  {

	bottom  b;

	std::cout << b.i_ << std::endl;

	std::thread ts [3];

    ts[0] = std::thread (&pusher);
    ts[1] = std::thread (&popper);
    ts[2] = std::thread (&counter);

    for (size_t i = 0; i < 3; ++i)
        ts [i].join();

    return EXIT_SUCCESS;
}

//-----------------------------------------------------------------------------

void *counter ()  {

    char    buffer [1024];
    int     count = 0;

    while (count++ < 60)  {
#ifndef WIN32
        const   struct  ::timespec  rqt = {1, 0};

        nanosleep (&rqt, NULL);
#endif // WIN32

        sprintf (buffer, "The number of current elements "
                         "in the queue is: %d\n", Q.size ());
        std::cout << buffer;
    }

    return NULL;
}

//-----------------------------------------------------------------------------

void *pusher ()  {

    char    buffer [1024];
    size_t  index = 0;
    int     count = 0;

    while (count++ < MAX_COUNT)  {
//        if (!(index % 500))  {
//            const   struct  ::timespec  rqt = {5, 0};

//            nanosleep (&rqt, NULL);
//        }
        Q.push (index);
        sprintf (buffer, "Pushed element %lu\n", index);
        std::cout << buffer;
        index += 1;
    }
    return NULL;
}

//-----------------------------------------------------------------------------

void *popper ()  {

    char    buffer [1024];
    size_t  index = 0;
    int     count = 0;

    while (count++ < MAX_COUNT)  {
        index += 1;

        if (! (index % 100))  {
            int i = 0;

            Q.pop_front (i);
            sprintf (buffer, "Poped element (pop_front()) %d\n", i);
            std::cout << buffer;
        }
        else  {
            const   int i = Q.front ();

            sprintf (buffer, "Poped element %d\n", i);
            std::cout << buffer;
            Q.pop();
        }
    }
    return NULL;
}

//-----------------------------------------------------------------------------

// Local Variables:
// mode:C++
// tab-width:4
// c-basic-offset:4
// End:
