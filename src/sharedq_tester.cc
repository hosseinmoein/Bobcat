// Hossein Moein
// October 22, 2009

#include <cstdlib>
#include <ctime>
#include <iostream>
#include <thread>

#include <Bobcat/SharedQueue.h>

using namespace hmq;

// ----------------------------------------------------------------------------

void *pusher ();
void *popper ();

static  const   int     MAX_COUNT = 100000;
SharedQueue<int>  Q;

// ----------------------------------------------------------------------------

int main (int argCnt, char *argVctr [])  {

	std::thread     ts [2];
    int             ret;
    const   time_t  start = ::time (NULL);

    ts[0] = std::thread (&pusher);
    ts[1] = std::thread (&popper);

    for (int i = 0; i < 2; ++i)
        ts [i].join();

    const   time_t  end = ::time (NULL);

    std::cout << "Total Elapsed Time: " << end - start
              << " seconds" << std::endl;
    return (EXIT_SUCCESS);
}

// ----------------------------------------------------------------------------

void *pusher ()  {

    char                        buffer [512];
    const   struct  ::timespec  rqt = { 0, 10000000 };

    for (int i = 1; i <= MAX_COUNT; ++i)  {
        Q.push (i);
        snprintf (buffer, sizeof(buffer) - 1, "Pushed %d\n", i);
        std::cout << buffer;

        // if (! (static_cast<int>(drand48 () * 100000.0) % 3))
        //     nanosleep (&rqt, NULL);
    }

    return (NULL);
}

// ----------------------------------------------------------------------------

void *popper ()  {

    char                        buffer [512];
    int                         i = 0;
    const   struct  ::timespec  rqt = { 0, 10000000 };

    while (true)  {
        try  {
            // i = Q.front ();
            // Q.pop ();
            i = Q.pop_front ();
            snprintf (buffer, sizeof(buffer) - 1, "Popped %d\n", i);
            std::cout << buffer;
            if (i >= MAX_COUNT)
                break;
        }
        catch (const SQEmpty &ex)  {
            if (i >= MAX_COUNT)
                break;
            std::cout << "Q Empty Exception\n";
        }

        // if (! (static_cast<int>(drand48 () * 100000.0) % 3))
        //     nanosleep (&rqt, NULL);
    }

    return (NULL);
}

// ----------------------------------------------------------------------------

// Local Variables:
// mode:C++
// tab-width:4
// c-basic-offset:4
// End:
