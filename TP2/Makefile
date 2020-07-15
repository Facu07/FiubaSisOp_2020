CC = g++ -pthread
CFLAGS = -o0 -g -Wall

##OBJECTS =
EXEC = inicializador

all: $(EXEC)

$(EXEC): $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) inicializador.cpp -o $(EXEC) -lm

run: $(EXEC)
	./$(EXEC)

clean:
	rm -f *.o $(EXEC)
