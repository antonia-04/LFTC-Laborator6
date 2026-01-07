## Mini-limbaj de programare (MLP) – specificație

* **Tipuri de date**

    * `int` – numere întregi pe 32 de biți

* **Declarații de variabile**

    * `int variabila;`

* **Instrucțiune de atribuire**

    * `variabila <- expresie_aritmetica;`

* **Instrucțiuni de citire**

    * `read variabila;` – citește un număr întreg de la intrare

* **Instrucțiuni de scriere**

    * `write variabila;` – afișează valoarea unei variabile

* **Expresii aritmetice**

    * formate din:

        * constante întregi
        * identificatori de variabile
        * operatori binari: `+`, `-`, `*`
        * paranteze rotunde `(` `)`
    * operatorii pot apărea de oricâte ori într-o expresie

* **Identificatori**

    * încep cu literă
    * pot conține litere, cifre și `_`
    * trebuie declarați înainte de utilizare

* **Structura programului**

    * programul este o succesiune de instrucțiuni
    * fiecare instrucțiune se termină cu `;`

* **Restricții**

    * nu sunt permise:
        * instrucțiuni condiționale
        * instrucțiuni repetitive
        * alte tipuri de date
        * funcții sau proceduri
    * limbajul este definit fără ambiguități
    * specificația Bison nu folosește directive de prioritate (`left`, `right`)
