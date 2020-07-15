#include <iostream>
#include <queue>
#include "simio.h"
#include "soga.h"
#include "defs.h"
#include "sv_sem.h"
#include "sv_shm.h"

#include <pthread.h>

using namespace std;


struct Orilla{
        int nombre;
        queue <Simio> colaSimios;
};
Orilla Norte, Sur, Este, Oeste;

void* thread_cargar_orilla(void*arg){	// Carga de manera Random, los monos en las distintas orillas segun la cantidad de monos que mandaron por parametro

    //orillas
    sv_sem mutexQueueNorte("mutexQueueNorte",1);
    sv_sem mutexQueueSur("mutexQueueSur",1);
    sv_sem mutexQueueEste("mutexQueueEste",1);
    sv_sem mutexQueueOeste("mutexQueueOeste",1);

	Simio tempSimio;
	tempSimio.nombre = rand();						// Random para el nombre de los Simios
	tempSimio.inicial = 1 + (rand()% 4); 			// Numeros randoms entre 1 y 4 para determinar en que orilla empiezan
	while(tempSimio.inicial == (tempSimio.direccion = 1 + (rand()% 4))){	
		tempSimio.direccion = 1 + (rand()% 4);		// Numeros randoms entre 1 y 4 para determinar en que orilla empiezan
	}
	switch(tempSimio.inicial){
		case NORTE:
			mutexQueueNorte.wait();
			Norte.colaSimios.push(tempSimio);
			mutexQueueNorte.post();
		break;
		case SUR:
			mutexQueueSur.wait();
			Sur.colaSimios.push(tempSimio);
			mutexQueueSur.post();
		break;
		case ESTE:
			mutexQueueEste.wait();
			Este.colaSimios.push(tempSimio);
			mutexQueueEste.post();
		break;
		case OESTE:
			mutexQueueEste.wait();
			Oeste.colaSimios.push(tempSimio);
			mutexQueueEste.post();
		break;
	}
}

void* carga_descarga(void*arg){

	//Soga
    sv_sem mutexSoga("mutexSoga",1);

    //orillas
    sv_sem mutexQueueNorte("mutexQueueNorte",1);
    sv_sem mutexQueueSur("mutexQueueSur",1);
    sv_sem mutexQueueEste("mutexQueueEste",1);
    sv_sem mutexQueueOeste("mutexQueueOeste",1);

	int contador = 0;
	bool salir = false;

	while(soga.cantMonos > contador){
		switch(soga.rutaActual){
		case NORTE:
			printf("Soga en Orilla Norte\n");
			printf("%d monos bajandose \n",soga.monosSubidos);
			soga.monosSubidos = 0;
			soga.rutaActual = SUR;
			while(!(Norte.colaSimios.empty()) && !salir){
				mutexSoga.wait();

				mutexQueueNorte.wait();
				//struct Simio simioActual = Norte.colaSimios.front();
				soga.monosSubidos ++;
				Norte.colaSimios.pop();
				contador ++;
				mutexQueueNorte.post();

				mutexSoga.post();

				if(soga.m <= soga.monosSubidos){
					salir = true;
				}
			}
			printf("Subieron %d simios en la soga \n", soga.monosSubidos);
			salir = false;
		break;
		case SUR:
			printf("Soga en Orilla Sur\n");
			printf("%d monos bajandose \n",soga.monosSubidos);
			soga.monosSubidos = 0;
			soga.rutaActual = ESTE;
			while(!(Sur.colaSimios.empty()) && !salir){
				mutexSoga.wait();

				mutexQueueSur.wait();
				//struct Simio simioActual = Sur.colaSimios.front();
				soga.monosSubidos ++;
				Sur.colaSimios.pop();
				contador ++;
				mutexQueueSur.post();

				mutexSoga.post();

				if(soga.m <= soga.monosSubidos){
					salir = true;
				}
			}
			printf("Subieron %d simios en la soga \n", soga.monosSubidos);
			salir = false;
		break;
		case ESTE:
			printf("Soga en Orilla Este\n");
			printf("%d monos bajandose \n",soga.monosSubidos);
			soga.monosSubidos = 0;
			soga.rutaActual = OESTE;
			while(!(Este.colaSimios.empty()) && !salir){ 
				mutexSoga.wait();

				mutexQueueEste.wait();
				//struct Simio simioActual = Este.colaSimios.front();
				soga.monosSubidos ++;
				Este.colaSimios.pop();
				contador ++;
				mutexQueueEste.post();

				mutexSoga.post();

				if(soga.m <= soga.monosSubidos){
					salir = true;
				}
			}
			printf("Subieron %d simios en la soga \n", soga.monosSubidos);
			salir = false;
		break;
		case OESTE:
			printf("Soga en Orilla Oeste\n");
			printf("%d monos bajandose \n",soga.monosSubidos);
			soga.monosSubidos = 0;
			soga.rutaActual = NORTE;
			while(!(Oeste.colaSimios.empty()) && !salir){
				mutexSoga.wait();

				mutexQueueOeste.wait();
				//struct Simio simioActual = Oeste.colaSimios.front();
				soga.monosSubidos ++;
				Oeste.colaSimios.pop();
				contador ++;
				mutexQueueOeste.post();

				mutexSoga.post();

				if(soga.m <= soga.monosSubidos){
					salir = true;
				}
			}
			printf("Subieron %d simios en la soga \n", soga.monosSubidos);
			salir = false;
		break;
		}
	}
}


/*-----------------------------------------------------	main 	-----------------------------------------------------*/

int main(int argc, char *argv[]) {

	cout << "INICIALIZADOR..." << endl;

	//imprimo los numeros de padron
	cout << 90928 << " ALVAREZ, NATALIA NAYLA" << endl;
	cout << 68180 << " BONINO, ADRIAN GUSTAVO" << endl;
	cout << 96029 << " WALTER, FACUNDO IVAN" << endl;
	cout << 105463 << " TROUCAN-JOUVE, CLEMENT"  << endl;
	cout << " " << endl;

	soga.m = atoi(argv[1]);
	soga.cantMonos = atoi(argv[2]);
	soga.monosSubidos = 0;
	soga.rutaActual = NORTE;		//Empieza para el NORTE

	Norte.nombre = NORTE;
	Sur.nombre = SUR;
	Este.nombre = ESTE;
	Oeste.nombre = OESTE;

	//soga
	sv_sem mutexSoga("mutexSoga",1);

	//orillas
	sv_sem mutexQueueNorte("mutexQueueNorte",1);
	sv_sem mutexQueueSur("mutexQueueSur",1);
	sv_sem mutexQueueEste("mutexQueueEste",1);
	sv_sem mutexQueueOeste("mutexQueueOeste",1);

	//sirve para generar los ids de los monos
	sv_sem mono_id("mono_id",1);

	//Aca habria q usar System V para crear los threads

	pthread_t threads_simios[soga.cantMonos];
	for(int i = 0; i < soga.cantMonos; i++){
        mono_id.wait();
        //sv_sem threads_simios("thread_simios", -1);
        pthread_create(&threads_simios[i],NULL,thread_cargar_orilla,NULL);
        mono_id.post();
	}

	//Aca tambien habria q usar System V para crear los threads
	pthread_t thread_soga;
	pthread_create(&thread_soga,NULL,carga_descarga,NULL);

	for(int i = 0; i < soga.cantMonos; i++){
		pthread_join(threads_simios[i], NULL);
	}

	pthread_join(thread_soga, NULL);


	return 0;
}
