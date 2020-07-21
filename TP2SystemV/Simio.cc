#include "../Sem-sv/sv_sem.h"
#include "../Sem-sv/sv_shm.h"
#include <iostream>
#include <sstream>
#include <vector>
#include "Coordinador.h"
#include "Varios.h"




int main (int argc, char* argv[])
{
    imprimir_padrones();
    if (argc != 4)
    {
        cout << "Uso: " << argv[0] << " <nombreSimio> <direccion_actual> <direccion_final>" << endl;
        return 1;
    }

    sv_sem sem_soga("semSoga");    
    Orilla* orilla;
    sv_shm area("area");
    orilla = reinterpret_cast<Orilla*>(area.map(BUFSIZ));

    Simio simio;
    simio.nombre= atoi(argv[1]);
    simio.dirInicial= atoi(argv[2]);
    simio.dirFinal= atoi(argv[3]);

    cout << "El simio se llama " << simio.nombre << endl;
    cout << "Quiere cruzar de la orilla  " << simio.dirInicial << endl;
    cout << "A la orilla " << simio.dirFinal << endl;

    switch (simio.dirInicial)
    {
        case NORTE:
            orilla->simiosOrillaNorte[orilla->cantSimiosOrillaNorte] = simio;
            orilla->cantSimiosOrillaNorte++;
            break;

        case SUR:            
            orilla->simiosOrillaSur[orilla->cantSimiosOrillaSur] = simio;
            orilla->cantSimiosOrillaSur++;
            break;

        case ESTE:
            orilla->simiosOrillaEste[orilla->cantSimiosOrillaEste] = simio;
            orilla->cantSimiosOrillaEste++;
            break;

        case OESTE:
            orilla->simiosOrillaOeste[orilla->cantSimiosOrillaOeste] = simio;
            orilla->cantSimiosOrillaOeste++;
            break;

                
        default:
            break;
    }

    if (!orilla->sogaMoviendose)
        orilla->orillaInicial = simio.dirInicial;

    // Lo llamo
    sem_soga.post();
    cout << "La soga fue utilizada" << endl;
    
    return 0;
} 
