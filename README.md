<center><h1><font size=`20px`>Space Battle</font></h1></center>

# Integrantes

### Yonatan José Guerra Pérez
### Abdel Fregel Hernández
### José Miguel Pérez Pérez

<font size=`3px`>

**`Space Battle`** es una simulación interactiva donde se modela el enfrentamiento entre dos equipos en un espacio determinado para lograr un objetivo, donde cada equipo puede interferir en las acciones del otro equipo.

En la simulación participan dos equipos conformados por un comandante y un conjunto de subordinados a su disposición, además, cada integrante de cada equipo esta equipado con la capacidad de destruir integrantes del equipo contrario. Cada equipo tiene por objetivo capturar la bandera del equipo contrario. La simulación llega a su fin en el momento en el que uno de los dos equipos capture la bandera del otro, uno de los dos comandantes sea destruido o ambos comandantes se queden sin subordinados.

## Escenario

La simulación se desarrolla en el cosmos, en un espacio de dimensiones finitas y repleto de obstáculos distribuidos de forma aleatoria por todo el espacio definido. Los equipos están formados por naves que pueden lanzar proyectiles y cada una tiene asociados unos puntos de vida y una cantidad de daño por disparo. Al comienzo los equipos se encuentran en extremos opuestos del mapa, al igual que las banderas insignias de cada equipo.

> ## Entidades involucradas

 - `Comandantes`:son aquellos agentes con la capacidad de ordenar a otros
 - `Subordinados`:son aquellos que obedecen las orientaciones que reciben del agente que lo dirige
 - `Obstáculos`:son las entidades a que modifican la estructura del terreno haciendo que sea imposible pasar sobre ellos para cualquier otra entidad que se pueda desplazar
 - `Proyectiles`:son entidades temporales cuyo objetivo es destruir entidades
 - `Banderas`:son el objetivo a conseguir por ambos equipos

> ## Relaciones definidas

 - `Comandante-Subordinado`: El comandante recibe toda la información proveniente de sus subordinados, a la vez que la procesa para planificar como conseguir el objetivo propuesto, y luego distribuir orientaciones entre sus subordinados para llevar a cabo el plan confeccionado.
 - `Naves(comandante/subordinado)-Proyectil`: Cada integrante de equipo puede disparar una vez cada cierto tiempo, cada proyectil es lanzado por alguna nave y si una nave es alcanzada por un proyectil, disminuye sus puntos de vida, si en algún momento los puntos de vida de una nave caen a 0 o por debajo de 0, esta nave es destruida(eliminada de la simulación).
 - `Naves(comandante/subordinado)-Bandera`: Cada nave puede capturar la bandera enemiga.La bandera tiene una cantidad de puntos de vida, esta se considera capturada cuando sus puntos de vida llegan a cero.
 - `Obstáculo-Proyectil`: Si un proyectil impacta con un obstáculo, dicho proyectil es destruido(eliminado de la simulación).
 - `Naves(comandante/subordinado)-Obstáculo`: Ninguna nave puede pasar por un punto en donde se encuentre un obstáculo.
 - `Nave-Nave`: Las naves pueden detectarse y destruirse mutuamente lanzando proyectiles.

> ## Procesos involucrados

 - `Búsqueda de la bandera`: En todo momento el comandante escucha lo que le informan sus subordinados para con esa información econtrar la bandera, defender su propia bandera o destruir naves enemigas.
 - `Ejecución de instrucciones`: En todo momento los subordinados realizan acciones independientes tales como defender o atacar hasta que les asigne un conjunto de instrucciones a ejecutar.

## Detalles

Los equipos siempre comienzan en el extremo correspondiente a su bandera insignia. Cada comandante tiene un grado de visión determinado, al igual que sus subordinados. El mapa del ambiente se genera por cuadrantes. Cada integrante de cada equipo tiene un tiempo de espera después de cada disparo. Las naves subordinadas se comportan de dos formas distintas; ejecutan las órdenes recibidas de su comandante y en caso de no tener ninguna, actúan de forma autónoma según lo más conveniente para ellas. La nave comandante es capaz de ver todo lo que sus subordinados ven.

## Interacción con el sistema

Es posible navegar por la simulación a través del teclado, para poder ver que sucede en distintos lugares de la simulación.

### Medio

 - `Controles del usuario`: a través de estos el usuario modifica el ambiente en el que se desarrollará la simulación.
 - `Pantalla`: es donde el usuario puede observar el desarrollo de la simulación.

## Variables de interés

A partir de las descripciones anteriores podemos reconocer las siguientes variables de interés:

 - $m$: cantidad de sectores en la dimensión $x$ del terreno de la simulación
 - $n$: cantidad de sectores en la dimensión $y$ del terreno de la simulación
 - $s$: dimensiones de los sectores del terreno de la simulación ($s$x$s$)
 - $V$: rango de visión de las naves
 - $F$: menor radio de distancia permitido para las naves enemigas
 - $S$: menor cantidad de naves dedicadas a buscar la bandera del equipo enemigo(ambos comandantes tratan de mantener esta cantidad a lo largo de la simulación)
 - $D$: menor cantidad de naves dedicadas a defender la bandera(mismo comportamiento de la variable anterior)
 - $SL$: latencia de lrazonamiento de los agentes subordinados
 - $CL$: latencia de razonamiento del agente comandante
 - $L$: puntos de vida de cada nave

## Objetivo
Se desea modelar la situación en que dos equipos contrarios intentan conseguir un objetivo en donde, la meta de uno significa un resultado negativo para el otro; y con las condiciones en que cada grupo posee un individuo al mando encargado de coordinar las acciones del resto de su comunidad y cada individuo solo es capaz de hacer un conjunto reducido de acciones. Dado lo anterior dicho, deseamos averiguar mediante experimentación que posición es mejor adoptar en este tipo de situaciones, atendiendo a las variables mencionadas anteriormente. La hipótesis es que es mejor tomar una posición ofensiva.

## Tecnologías usadas

> ## Godot 3.5

Es un motor de desarrollo de videojuegos de código abierto y gratuito que permite a el desarrollo juegos 2D y 3D. Fue lanzado en 2014 y se ha vuelto ampliamente conocido por su enfoque en la facilidad de uso, la flexibilidad y la eficiencia, lo que lo hace accesible tanto para principiantes como para desarrolladores experimentados. El motor de Godot ofrece una amplia gama de características, incluyendo:

 - `Editor de Escenas`: Permite a los desarrolladores construir juegos visualmente, arrastrando y soltando objetos en un espacio 2D o 3D.
 - `Sistema de Nodos`: Utiliza un sistema de nodos para organizar el código y los recursos, facilitando la reutilización y la modularidad.
 - `Scripting`: Soporta GDScript, un lenguaje de scripting propio que es similar a Python, así como C# y C++.
 - `Renderizado`: Ofrece soporte para renderizado 2D y 3D, incluyendo soporte para VR/AR.
 - `Motor de Física`: Incluye un motor de física integrado que soporta tanto física 2D como 3D.
 - `Soporte para Múltiples Plataformas`: Permite exportar juegos a una amplia gama de plataformas, incluyendo Windows, macOS, Linux, iOS, Android, y más.

## Arquitectura de la simulación

Toda la simulación está implementada en Godot. Las escenas se pueden dividir en 3 grupos principales:
 - `Escena principal`: es en la que se desarrolla toda la simulación, y en al que se encuentran todas las entidades involucradas.
 - `Escenas relacionadas a la lógica de la simulación`: son aquellas que se encargan de controlar el flujo de la simulación, al igual que ciertos aspectos y parámetros de esta, como el terreno y el rango de visión.
 - `Escenas relacionadas a los agentes`: son las que están destinadas al funcionamiento de los agentes.


## Agentes

En la simulación hay dos tipos de agentes principales, **deductivos**(las naves subordinadas) y **de razonamiento práctico**(los comandantes)

### Agentes subordinados

Estos agentes basan su comportamiento en un conjunto de reglas de deducción internas para decidir que acción realizar en cada momento. Estos son básicamente una máquina de estados, donde según la percepción actual que tengan de su entorno y las reglas de deducción que possen, pueden cambiar o mantener el estado interno de ellos, las acciones que realiza el agente depende del estado en el que se encuentra. Esta arquitectura es sencilla de implementar y comprender, y se adapta a la situación que deseamos modelar.

### Agentes comandantes

Estos agentes siguen una arquitectura **BDI** para poder **razonar** sobre su ambiente y las decisiones que desea tomar para lograr sus objetivos, los cuales van cambiando a lo largo de la simulación, pues aunque el objetivo principal es capturar la bandera enemiga, deben poder escoger entre defender o atacar. Es por eso que consideramos que una arquitectura **BDI** era más adecuada para el objetivo buscado, ya que permite modelar el processo de razonamiento para obtener la acción a realizar.

### Generación de estrategias

Dada el objetivo a realizar decidido por el comandante, este realiza un proceso de búsqueda de la mejor forma de conseguirlo, moviéndose a través de los posibles de estados a los que puede acceder desde el estado en que se encuentra, hasta que llegue a un estado en el cual se cumplen las restricciones para las cuales se considera que el objetivo se ha cumplido. Un estado es una distribución de naves en el mapa con las instrucciones dadas.

## Experimentación

A través de experimentación se seleccionaron los valores siguientes parámetros para las simulaciones:

 - $m$: 8
 - $n$: 15
 - $s$: 10
 - $V$: 700
 - $S$: 25
 - $SL$: 10
 - $CL$: 100
 - $L$: 3000

Estos valores fueron seleccionados debido a que se observó mayor cantidad de acciones interesantes de manera general por parte de ambos equipos, a la vez que permitía a ambos equipos desarrollarse de mejores maneras y se acercaban más al tipo de situaciones que se deseaba modelar.

La salida de cada simulación viene dada en el formato siguiente:

 - `SIZE`: una tupla $(n,m)$ con las dimensiones del terreno
 - `SOLDIERS`: cantidad de naves por cada equipo
 - `VISION_RANGE`: rango de visión de cada nave
 - `SOLDIER_REASONING_LATENCY`: latencya de razonamiento de cada nave subordinada
 - `COMMANDER_REASONING_LATENCY`: latencia de razonameitno del comandante
 - `FLAG_DEFENSIVE_RATIO`: radio defensivo de la bandera de cada equipo
 - `LIFE_POINTS`: puntos de vida de cada nave
 - `USER_MAX_DEFENDERS`: cantidad de naves que el equipo *user* destina a la defensa
 - `USER_MAX_SEEKERS`: cantidad de naves que el equipo *user* destina al ataque
 - `ENEMY_MAX_DEFENDERS`: cantidad de naves que el equipo *enemy* destina a la defensa
 - `ENEMY_MAX_SEEKERS`: cantidad de naves que el equipo *enemy* destina a la ataque
 - `LOOSER_TEAM`: equipo que perdio
 - `HISTORY`: resultados del enfrentamiento, contiene dos valores, uno para el equipo *user* y otro para el equipo *enemy*, donde cada valor tiene el formato:`TEAM` -> (`OFFENSIVE_ACTIONS`,`DEFENSIVE_ACTIONS`,`FLAG_CAPTURE_ATTEMPS`)

### Resultados

Se realizó un total de 4886 simulaciones. Dado que nuestra hipótesis se basa en que posición asume un equipo, si ofensiva o defensiva, tuvimos que definir criterios para decidir que posicion asumió un equipo, estos fueron:

 - `1 - posición general`: decimos que un equipo tuvo una posición general ofensiva si destinó más naves a la ofensiva que a la defensiva, en otro caso, decimos que adoptó una posición defensiva
 - `2 - intentos de capturar la bandera enemiga`: decimos que un equipo tuvo una posición ofensiva si hizo 200 intentos más de capturar la bandera que el otro equipo, en caso de no poder decidir, decimos que ambos equipos estuvieron en una posición defensiva
 - `3 - acciones ofensivas`: se sigue un criterio similar al anterior
 - `4 - acciones defensivas`: similar al anterior, pero el que tuvo más acciones defensivas se dice que estuvo a la defensiva, y el otro en offensiva.

Los datos fueron procesados y los resultados fueron los siguientes:

> ### veces que el equipo ofensivo consiguió la victoria:

 - usando el criterio 1: 1941
 - usando el criterio 2: 43
 - usando el criterio 3: 16
 - usando el criterio 4: 39

> ### veces que el equipo *user* estuvo a la ofensiva:
 - usando el criterio 1: 1951
 - usando el criterio 2: 48
 - usando el criterio 3: 13
 - usando el criterio 4: 41

> ### veces que el equipo *enemy* estuvo a la ofensiva
 - usando el criterio 1: 4769
 - usando el criterio 2: 32
 - usando el criterio 3: 34
 - usando el criterio 4: 30

> ### Cantidad de victorias del equipo *users*: 4694,
> ### Cantidad de victorias del equipo *enemy*: 181,
> ### Total de encuentros: 4886

## Análisis estadístico:

De estos resultados vemos que en el 39% de los enfrentamientos no ganó el equipo que se encontraba a la ofensiva. Dado que nuestra hipótesis es que es mejor optar una posición ofensiva. Esto lo podemos escribir como, en este tipo de situaciones, optar por una posición ofensiva nos asegura ganar en más del 50% de los casos. Para comprobar o refutar nuestra hipótesis, realizaremos una prueba de hipótesis para proporciones con parámetro $p$ de la distribución $B(n,p)$

> ### Hipótesis

$H_0:p \leq 0.5$

$H_1: p > 0.5$

Rechazamos $H_0$ si $\overline{Z} < Z_{\alpha}$, tomando $\alpha = 0.05$, tenemos que:
$\overline{p} = \frac{1941}{4886} = 0,39725747$
luego $\overline{Z} = \frac{\overline{p} - p_0}{\sqrt{p_0}(1 - p_0)}\sqrt{n}$

$\overline{Z} = \frac{0,39725747 - 0.5}{\sqrt{0.5(1 - 0.5)}}\sqrt{4886}$

$\overline{Z} = \frac{-0,10274253}{0.5} 69,899928469 = -14,363390995 < 1.645$

Donde 1.645 es el valor crítico asociado, luego, no hay suficiente evidencia para rechazar la hipótesis nula, luego, no podemos asumir que en este tipo de situaciones es mejor adoptar una posición ofensiva.