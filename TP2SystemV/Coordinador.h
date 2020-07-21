#ifndef COORDINADOR_H
#define COORDINADOR_H
#define m 4




struct Simio {
    int nombre;
    int dirInicial;
    int dirFinal;
    
};

struct Orilla {
    int nombre;
    int cantSimiosOrillaNorte;
    int cantSimiosOrillaSur;
    int cantSimiosOrillaOeste;
    int cantSimiosOrillaEste;
    Simio simiosOrillaNorte[m];
    Simio simiosOrillaSur[m];
    Simio simiosOrillaOeste[m];
    Simio simiosOrillaEste[m];
    bool sogaMoviendose;
    int orillaInicial;
};


#endif
