// Hossein Moein
// October 24, 2009

#include <cstdlib>
#include <cstdio>
#include <ctime>
#include <iostream>
#include <string.h>
#include <thread>

#include <Bobcat/LockFreeQueue.h>

using namespace hmq;

// ----------------------------------------------------------------------------

void pusher ();
void popper ();

struct Dummy {

    std::string stdstr { };
    int         i1 { 0 };
    double      d1 { 0.0 };
    char        *str { nullptr };

    ~Dummy ()  { delete[] str; }
    Dummy () = default;
    Dummy (const char *ss, int i, double d, const char *s)
        : stdstr (ss), i1 (i), d1 (d)  {

        if (s)  {
            str = new char[strlen (s) + 1];
            strcpy (str, s);
        }
    }
    Dummy (const Dummy &other)  {

        stdstr = other.stdstr;
        i1 = other.i1;
        d1 = other.d1;
        if (other.str)  {
            str = new char[strlen (other.str) + 1];
            strcpy (str, other.str);
        }
    }
    Dummy &operator = (const Dummy &rhs)  {

        if (this != &rhs)  {
            stdstr = rhs.stdstr;
            i1 = rhs.i1;
            d1 = rhs.d1;
            if (rhs.str)  {
                const size_t    rhs_len = strlen (rhs.str);

                if (str == nullptr || strlen(str) < rhs_len)  {
                    delete[] str;
                    str = new char[rhs_len + 1];
                }
                strcpy (str, rhs.str);
            }
        }
        return (*this);
    }

    Dummy (Dummy &&other)  {

        stdstr = std::move(other.stdstr);
        i1 = other.i1;
        d1 = other.d1;
        str = other.str;
        other.str = nullptr;
    }
    Dummy &operator = (Dummy &&rhs)  {

        if (this != &rhs)  {
            stdstr = std::move(rhs.stdstr);
            i1 = rhs.i1;
            d1 = rhs.d1;
            str = rhs.str;
            rhs.str = nullptr;
        }
        return (*this);
    }
};

static  const   int         MAX_COUNT = 100000;

int                   pushed = 0;
int                   popped = 0;
LockFreeQueue<Dummy>  Q;

// ----------------------------------------------------------------------------

int main (int argCnt, char *argVctr [])  {

	std::thread     ts [2];
    int             ret;
    const   time_t  start = ::time (nullptr);

    ts[0] = std::thread (&pusher);
    ts[1] = std::thread (&popper);

    for (int i = 0; i < 2; ++i)
        ts [i].join();

    const   time_t  end = ::time (nullptr);

    std::cout << "Total Elapsed Time: " << end - start
              << " seconds" << std::endl;
    std::cout << "Q Cache Count: " << Q.cache_size () << std::endl;
    std::cout << "New Count: " << Q.new_count () << std::endl;
    std::cout << "Pushed: " << pushed << std::endl;
    std::cout << "Popped: " << popped << std::endl;
    return (EXIT_SUCCESS);
}

// ----------------------------------------------------------------------------

void pusher ()  {

    char                        buffer [512];
    const   struct  ::timespec  rqt = { 0, 100000 };

    for (int i = 1; i <= MAX_COUNT; ++i)  {
        // Q.push (i);
        Q.push (Dummy ("This is a str", i, i + 10,  "This is a str 2"));
        sprintf (buffer, "Pushed %d\n", i);
        std::cout << buffer;
        pushed += 1;

        // if (! (static_cast<int>(drand48 () * 100000.0) % 3))
        //     nanosleep (&rqt, nullptr);
    }

    return;
}

// ----------------------------------------------------------------------------

void popper ()  {

    char                        buffer [512];
    int                         i = 0;
    const   struct  ::timespec  rqt = { 0, 100000 };

    while (true)  {
        try  {
            // i = Q.front ();
            // Q.pop ();
            // i = Q.pop_front ();
            const Dummy d = Q.pop_front ();

            i = d.i1;
            sprintf (buffer, "Popped %d\n", d.i1);
            std::cout << buffer;
            popped += 1;
        }
        catch (const LFQEmpty &ex)  {
            if (i >= MAX_COUNT)
                break;
            // std::cout << "Q Empty Exception\n";
        }

        // if (! (static_cast<int>(drand48 () * 100000.0) % 3))
        //     nanosleep (&rqt, nullptr);
    }

    return;
}

// ----------------------------------------------------------------------------

// Local Variables:
// mode:C++
// tab-width:4
// c-basic-offset:4
// End:
