#include "../Sem-sv/sv_sem.h"
#include "../Sem-sv/sv_shm.h"
#include "Coordinador.h"
#include "Varios.h"
using namespace std;


int main()
{   
    imprimir_padrones();
    sv_shm area("area");
    sv_sem sem_soga("semSoga",1);
    
    sem_soga.post();    
   
return 0; 
}
