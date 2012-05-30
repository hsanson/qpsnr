#Makefile generated by amake
#On Wed Feb 17 10:48:47 2010
#To print amake help use 'amake --help'.
CC=gcc
CPPC=g++
LINK=g++
SRCDIR=src
OBJDIR=obj
FLAGS=-O2 -pthread
LIBS=-lavcodec -lavformat -lswscale -ljpeg
OBJS=$(OBJDIR)/qav.o $(OBJDIR)/stats.o $(OBJDIR)/main.o $(OBJDIR)/settings.o 
EXEC=qpsnr

$(EXEC) : $(OBJS)
	$(LINK) $(OBJS) -o $(EXEC) $(FLAGS) $(LIBS)

$(OBJDIR)/qav.o: src/qav.cpp src/qav.h src/settings.h $(OBJDIR)/__setup_obj_dir
	$(CPPC) $(FLAGS) src/qav.cpp -c -o $@

$(OBJDIR)/stats.o: src/stats.cpp src/stats.h src/mt.h src/shared_ptr.h \
 src/settings.h $(OBJDIR)/__setup_obj_dir
	$(CPPC) $(FLAGS) src/stats.cpp -c -o $@

$(OBJDIR)/main.o: src/main.cpp src/mt.h src/shared_ptr.h src/qav.h src/settings.h \
 src/stats.h $(OBJDIR)/__setup_obj_dir
	$(CPPC) $(FLAGS) src/main.cpp -c -o $@

$(OBJDIR)/settings.o: src/settings.cpp src/settings.h $(OBJDIR)/__setup_obj_dir
	$(CPPC) $(FLAGS) src/settings.cpp -c -o $@

$(OBJDIR)/__setup_obj_dir :
	mkdir -p $(OBJDIR)
	touch $(OBJDIR)/__setup_obj_dir

.PHONY: clean bzip

clean :
	rm -rf $(OBJDIR)/*.o
	rm -rf $(EXEC)

bzip :
	tar -cvf $(EXEC).tar $(SRCDIR)/* Makefile
	bzip2 $(EXEC).tar

