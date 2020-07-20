#include <iostream>
#include <queue>
#include "sv_sem.h"
#include "sv_shm.h"
#include "defs.h"
#include <pthread.h>
using namespace std;

int main(int argc, char *argv[]) {
   
	//Soga
	sv_sem mutexSoga("mutexSoga",1);

	//orillas
	sv_sem mutexQueueNorte("mutexQueueNorte",1);
	sv_sem mutexQueueSur("mutexQueueSur",1);
	sv_sem mutexQueueEste("mutexQueueEste",1);
	sv_sem mutexQueueOeste("mutexQueueOeste",1);
	
	//mono
    sv_sem mono_id("mono_id",1);

	mono_id.post();
	mutexSoga.post();
	mutexQueueNorte.post();
	mutexQueueSur.post();
	mutexQueueEste.post();
	mutexQueueOeste.post();

	return 0;
}
