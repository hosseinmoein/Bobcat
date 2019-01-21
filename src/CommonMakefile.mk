## Hossein Moein
## July 17 2009

LOCAL_LIB_DIR = ../lib/$(BUILD_PLATFORM)
LOCAL_BIN_DIR = ../bin/$(BUILD_PLATFORM)
LOCAL_OBJ_DIR = ../obj/$(BUILD_PLATFORM)
LOCAL_INCLUDE_DIR = ../include
PROJECT_LIB_DIR = ../../lib/$(BUILD_PLATFORM)
PROJECT_LIB_DIR = ../../bin/$(BUILD_PLATFORM)
PROJECT_INCLUDE_DIR = ../../include

# -----------------------------------------------------------------------------

SRCS =
HEADERS = $(LOCAL_INCLUDE_DIR)/SharedQueue.h \
          $(LOCAL_INCLUDE_DIR)/SharedQueue.tcc \
          $(LOCAL_INCLUDE_DIR)/LockFreeQueue.h \
          $(LOCAL_INCLUDE_DIR)/LockFreeQueue.tcc \
          $(LOCAL_INCLUDE_DIR)/FixedSizeQueue.h \
          $(LOCAL_INCLUDE_DIR)/FixedSizeQueue.tcc

LIB_NAME =
TARGET_LIB =

TARGETS += $(LOCAL_BIN_DIR)/sharedq_tester \
           $(LOCAL_BIN_DIR)/lockfreeq_tester \
           $(LOCAL_BIN_DIR)/fixedsizeq_tester

# -----------------------------------------------------------------------------

LFLAGS += -Bstatic -L$(LOCAL_LIB_DIR) -L$(PROJECT_LIB_DIR)

LIBS = $(LFLAGS) $(PLATFORM_LIBS)
INCLUDES += -I. -I$(LOCAL_INCLUDE_DIR) -I$(PROJECT_INCLUDE_DIR)
DEFINES = -D_REENTRANT -DDMS_INCLUDE_SOURCE -DDMS_$(BUILD_DEFINE)__

# -----------------------------------------------------------------------------

# object file
#
LIB_OBJS =

# -----------------------------------------------------------------------------

# set up C++ suffixes and relationship between .cc and .o files
#
.SUFFIXES: .cc

$(LOCAL_OBJ_DIR)/%.o: %.cc
	$(CXX) $(CXXFLAGS) -c $< -o $@

.cc :
	$(CXX) $(CXXFLAGS) $< -o $@ -lm $(TLIB) -lg++
#	$(CXX) $(CXXFLAGS) $< -o $@ -lm $(TLIB)

# -----------------------------------------------------------------------------

all: PRE_BUILD $(TARGETS)

PRE_BUILD:
	mkdir -p $(LOCAL_LIB_DIR)
	mkdir -p $(LOCAL_BIN_DIR)
	mkdir -p $(LOCAL_OBJ_DIR)
	mkdir -p $(PROJECT_LIB_DIR)
	mkdir -p $(PROJECT_INCLUDE_DIR)

SHAREDQ_TESTER_OBJ = $(LOCAL_OBJ_DIR)/sharedq_tester.o
$(LOCAL_BIN_DIR)/sharedq_tester: $(TARGET_LIB) $(SHAREDQ_TESTER_OBJ)
	$(CXX) -o $@ $(SHAREDQ_TESTER_OBJ) $(LIBS)

LOCKFREEQ_TESTER_OBJ = $(LOCAL_OBJ_DIR)/lockfreeq_tester.o
$(LOCAL_BIN_DIR)/lockfreeq_tester: $(TARGET_LIB) $(LOCKFREEQ_TESTER_OBJ)
	$(CXX) -o $@ $(LOCKFREEQ_TESTER_OBJ) $(LIBS)

FIXEDSIZEQ_TESTER_OBJ = $(LOCAL_OBJ_DIR)/fixedsizeq_tester.o
$(LOCAL_BIN_DIR)/fixedsizeq_tester: $(TARGET_LIB) $(FIXEDSIZEQ_TESTER_OBJ)
	$(CXX) -o $@ $(FIXEDSIZEQ_TESTER_OBJ) $(LIBS)

# -----------------------------------------------------------------------------

depend:
	makedepend $(CXXFLAGS) -Y $(SRCS)

clean:
	rm -f $(LIB_OBJS)

clobber:
	rm -f $(TARGETS) $(SHAREDQ_TESTER_OBJ) $(LOCKFREEQ_TESTER_OBJ) \
              $(FIXEDSIZEQ_TESTER_OBJ)

install_hdr:
	cp -pf $(HEADERS) $(PROJECT_INCLUDE_DIR)/.

# -----------------------------------------------------------------------------

## Local Variables:
## mode:Makefile
## tab-width:4
## End:
