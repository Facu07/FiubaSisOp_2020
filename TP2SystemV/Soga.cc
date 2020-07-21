#include <iostream>
#include <vector>
#include "../Sem-sv/sv_sem.h"
#include "../Sem-sv/sv_shm.h"
#include "Coordinador.h"
#include "Varios.h"

using namespace std;

class Soga
{
    private:
    sv_sem sem_soga;
    sv_shm area;
    Orilla* orilla;
    int dirInicial =1; 
    int dirFinal =1; 
    int capacidad = 10;
    vector<Simio> simios;
    public:
    Soga();
    void EsperarSoga();
    bool HizoCruce();
    void MoverSoga();
    void BajarSimios();
    void SubirSimios();
    int CapacidadActual();
    bool HayLugar();
    bool EstaMoviendose();
    int ObtenerCantidadSimiosActual();
    Simio* ObtenerSimiosActual();
    void BuscarProximoCruce();
    void BuscarProximoCruceEnOrilla(int orilla);
    void BuscarProximoCruceEnOrillaAnterior();
    void BuscarProximoCruceEnOrillaSiguiente();
  
};

Soga::Soga() : sem_soga("semSoga"), area("area")
{
    orilla = reinterpret_cast<Orilla*>(area.map(BUFSIZ));
    
};

void Soga::EsperarSoga()
{
    orilla->sogaMoviendose = false;
    sem_soga.wait();
    cout << "Se mueve la soga desde la orilla " << orilla->orillaInicial << endl;
    dirFinal = orilla->orillaInicial;
    orilla->sogaMoviendose =true;
}

bool Soga::HizoCruce()
{
    return dirInicial == dirFinal && dirFinal != orilla-> orillaInicial;
}

void Soga::MoverSoga()
{
    if (dirFinal > dirInicial)
        dirInicial++;
    else if (dirFinal < dirInicial)
        dirInicial--;

    cout << "***** DIRECCION: " << dirInicial << " *****" << endl;
   
}

void Soga::BajarSimios()
{
    if (simios.empty())
    {
        cout << "Ningun simio se baja" << endl;
        return;
    }

    vector<Simio> simiosEnSoga;

    for (int i=0; i < simios.size(); i++)
    {
        Simio simio = simios.at(i);

        if (simio.dirFinal == dirInicial)
        {
            cout << "El simio " << simio.nombre << " se baja en esta orilla." << endl;
        }
        else
        {
            simiosEnSoga.push_back(simio);
        }        
    }

    simios = simiosEnSoga;
}

void Soga::SubirSimios()
{
    if (!HayLugar())
    {
        cout << "No hay más lugar en la soga." << endl;
        return;
    }
    else
    {
        cout << "Hay lugar en la soga." << endl;
    }

    int cantidadSimiosDirActual = ObtenerCantidadSimiosActual();

    if (cantidadSimiosDirActual == 0)
    {
        cout << "No hay simios esperando a subir en esta orilla." << endl;
        return;
    }
    else
    {
        cout << "Hay " << cantidadSimiosDirActual << " simios en esta orilla" << endl;
    }

    Simio* simiosDirActual = ObtenerSimiosActual();

    vector<Simio> proximosSimios;
    Simio simiosEnSoga[10];
    int cantSimiosEnSoga = 0;

    for (int i=0; i < cantidadSimiosDirActual; i++)
    {
        Simio simioActual = *(simiosDirActual + i);

        if (dirInicial == orilla->orillaInicial)
        {
            if (simios.size() > 0)
                sem_soga.wait();

            simios.push_back(simioActual);

            cout << "Se sube un simio." << endl;

            dirFinal = simioActual.dirFinal;
        }
        else if (EstaMoviendose() && (simioActual.dirFinal > dirInicial) && HayLugar())
        {
            sem_soga.wait();
            simios.push_back(simioActual);

            cout << "Se sube un simio." << endl;
            
            if (simioActual.dirFinal > dirFinal)
                dirFinal = simioActual.dirFinal;
        }
        else if (!EstaMoviendose() && (simioActual.dirFinal < dirInicial) && HayLugar())
        {
            sem_soga.wait();
            simios.push_back(simioActual);

            cout << "Se sube un simio." << endl;
            
            if (simioActual.dirFinal < dirFinal)
                dirFinal = simioActual.dirFinal;
        }
        else
        {
            cout << "El simio no se sube." << endl;

            simiosEnSoga[cantSimiosEnSoga] = simioActual;
            cantSimiosEnSoga++;
        }
    }

    cout << "Ya subieron todos los simios." << endl;
    
    switch (dirInicial)
    {
        case NORTE:
            copy(begin(simiosEnSoga), end(simiosEnSoga), begin(orilla->simiosOrillaNorte));
            orilla->cantSimiosOrillaNorte = cantSimiosEnSoga;
            break;

        case SUR:
            copy(begin(simiosEnSoga), end(simiosEnSoga), begin(orilla->simiosOrillaSur));
            orilla->cantSimiosOrillaSur = cantSimiosEnSoga;
            break;

        case ESTE:
            copy(begin(simiosEnSoga), end(simiosEnSoga), begin(orilla->simiosOrillaEste));
            orilla->cantSimiosOrillaEste = cantSimiosEnSoga;
            break;

        case OESTE:
            copy(begin(simiosEnSoga), end(simiosEnSoga), begin(orilla->simiosOrillaOeste));
            orilla->cantSimiosOrillaOeste = cantSimiosEnSoga;
            break;
        
        default:
            break;
    }
}

int Soga::CapacidadActual()
{
    return capacidad - simios.size();
}

bool Soga::HayLugar()
{
    return capacidad > simios.size();
}

bool Soga::EstaMoviendose()
{
    return dirInicial == 1 || dirFinal > dirInicial;
}

Simio* Soga::ObtenerSimiosActual()
{
    switch (dirInicial)
    {
        case NORTE:
            return orilla->simiosOrillaNorte;            

        case SUR:
            return orilla->simiosOrillaSur;             

        case ESTE:
            return orilla->simiosOrillaEste;             

        case OESTE:
            return orilla->simiosOrillaOeste;             
 
        default:            
            return nullptr;
    }
}

int Soga::ObtenerCantidadSimiosActual()
{
    switch (dirInicial)
    {
        case NORTE:
            return orilla->cantSimiosOrillaNorte;

        case SUR:
            return orilla->cantSimiosOrillaSur;       

        case ESTE:
            return orilla->cantSimiosOrillaEste;

        case OESTE:
            return orilla->cantSimiosOrillaOeste;

        default:            
            return 0;
    }
}

void Soga::BuscarProximoCruce()
{
    cout << "Buscando próxima orilla" << endl;

    BuscarProximoCruceEnOrilla(dirInicial);

    if (EstaMoviendose() && HizoCruce())
        BuscarProximoCruceEnOrillaSiguiente();

    if (!EstaMoviendose() && HizoCruce())
        BuscarProximoCruceEnOrillaAnterior();

    if (HizoCruce())
        cout << "No hay más simios esperando la soga." << endl;
    else
        cout << "Hay un simio esperando en la orilla " << dirFinal << endl;
}

void Soga::BuscarProximoCruceEnOrilla(int orillaD)
{
    if (!HizoCruce())
        return;

    switch (orillaD)
    {
        case NORTE:
            if (orilla->cantSimiosOrillaNorte > 0)
            {
                dirFinal = orilla->simiosOrillaNorte[0].dirFinal;
            }
            break;

        case SUR:
            if (orilla->cantSimiosOrillaSur > 0)
            {
                dirFinal = orilla->simiosOrillaSur[0].dirFinal;
            }
            break;

        case ESTE:
            if (orilla->cantSimiosOrillaEste > 0)
            {
                dirFinal = orilla->simiosOrillaEste[0].dirFinal;
            }
            break;

        case OESTE:
            if (orilla->cantSimiosOrillaOeste > 0)
            {
                dirFinal = orilla->simiosOrillaOeste[0].dirFinal;
            }
            break;
        
        default:
            break;
    }
}
void Soga::BuscarProximoCruceEnOrillaSiguiente()
{
    switch (dirInicial)
    {
        case NORTE:
            BuscarProximoCruceEnOrilla(SUR);
            BuscarProximoCruceEnOrilla(ESTE);
	    BuscarProximoCruceEnOrilla(OESTE);
            break;

        case SUR:
            BuscarProximoCruceEnOrilla(ESTE);
	    BuscarProximoCruceEnOrilla(OESTE);
            break;

        case ESTE:
            BuscarProximoCruceEnOrilla(OESTE);
            break;

        default:
            break;
    }
}
void Soga::BuscarProximoCruceEnOrillaAnterior()
{
    switch (dirInicial)
    {
        case OESTE:
            BuscarProximoCruceEnOrilla(ESTE);
            BuscarProximoCruceEnOrilla(SUR);
	    BuscarProximoCruceEnOrilla(NORTE);
            break;

        case ESTE:
            BuscarProximoCruceEnOrilla(SUR);
	    BuscarProximoCruceEnOrilla(NORTE);
            break;

        case SUR:
            BuscarProximoCruceEnOrilla(NORTE);
            break;

        default:
            break;
    }
}

int main(int argc, char * argv[])
{    
    imprimir_padrones();
    Soga soga;
    

    while (true)
    {
        soga.EsperarSoga();

        while (!soga.HizoCruce())
        {
            soga.MoverSoga();
	    soga.BajarSimios();
            soga.SubirSimios();
            sleep(5);

            if (soga.HizoCruce())
                soga.BuscarProximoCruce();
        }
        
    }

    return 0;
}
