#include "../Sem-sv/sv_sem.h"
#include "../Sem-sv/sv_shm.h"
#include <iostream>
#include <sstream>
#include "Coordinador.h"
#include "Varios.h"

int main (){
    imprimir_padrones();
    sv_sem sem_soga("semSoga",0);    
    cout<<"Semaforos inicializados"<<endl;
    Orilla* orilla;
    sv_shm area("area");
    orilla= reinterpret_cast<Orilla*>(area.map(sizeof(Orilla)));
    cout<<"Area inicializada"<<endl;
    
    

    return 0;
} 

