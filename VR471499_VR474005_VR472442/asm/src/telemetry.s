.section .data

pilot_0_str:
    .string "Pierre Gasly\0"
pilot_1_str:
    .string "Charles Leclerc\0"
pilot_2_str:
    .string "Max Verstappen\0"
pilot_3_str:
    .string "Lando Norris\0"
pilot_4_str:
    .string "Sebastian Vettel\0"
pilot_5_str:
    .string "Daniel Ricciardo\0"
pilot_6_str: 
    .string "Lance Stroll\0"
pilot_7_str:
    .string "Carlos Sainz\0"
pilot_8_str:
    .string "Antonio Giovinazzi\0"
pilot_9_str:
    .string "Kevin Magnussen\0"
pilot_10_str:
    .string "Alexander Albon\0"
pilot_11_str:
    .string "Nicholas Latifi\0"
pilot_12_str:
    .string "Lewis Hamilton\0"
pilot_13_str:
    .string "Romain Grosjean\0"
pilot_14_str:
    .string "George Russell\0"
pilot_15_str:
    .string "Sergio Perez\0"
pilot_16_str:
    .string "Daniil Kvyat\0"
pilot_17_str:
    .string "Kimi Raikkonen\0"
pilot_18_str:
    .string "Esteban Ocon\0"
pilot_19_str:
    .string "Valtteri Bottas\0"
invalid_pilot_str:
    .string "Invalid\n"



#dichiarazione variabili per la stampa dei livelli dei parametri: velocità, rpm, temperatura
BASSO:
    .string "LOW\0"
MEDIO:
    .string "MEDIUM\0"
ALTO:
    .string "HIGH\0"



.section .text #dichiarazione delle funzioni usate, la funzione global è "telemetry"
    .global telemetry

    #converte le stringhe del file di input in interi
    .type atoi, @function

    #scorre il puntatore dell'input finché non trova una virgola tra i caratteri
    .type virgola, @function

    #aggiorna il valore che abbiamo pushato sullo stack quando trova un valore rpm maggiore
    .type find_max_rpm, @function

    #aggiorna il valore che abbiamo pushato sullo stack quando trova un valore tempo maggiore
    .type find_max_temp, @function

    #aggiorna il valore che abbiamo pushato sullo stack quando trova un valore velocità maggiore
    .type find_max_vel, @function

    #scrive sul file di output il tempo
    .type write_time, @function

    #scrive sul file di output ciò a cui punta %esi: il livello (HIGH - LOW - MEDIUM) di rmp, temperatura e velocità, o invalid
    .type write, @function

    #scrive sul file di output ciò che è contenuto in %eax: i massimi e la media
    .type write_end, @function



telemetry:
    #salvo il base pointer nello stack
    pushl %ebp
    #faccio puntare lo stack pointer al base pointer
    movl %esp, %ebp
    #recupero l'indirizzo del file di input
    movl 8(%esp), %esi  
    #recupero l'indirizzo del file di output
    movl 12(%esp), %edi
    #creo lo spazio nello stack per salvarmi i massimi e i componenti della media
    pushl $0 #-4(%ebp)  - massimo rpm
    pushl $0 #-8(%ebp)  - massima temperatura
    pushl $0 #-12(%ebp) - massima velocità
    pushl $0 #-16(%ebp) - somma delle velocità
    pushl $0 #-20(%ebp) - contatore
    #salvo %ebx per ripristinarlo quando esco da telemetry
    pushl %ebx

    #principalmente usati per:
    xorl %eax, %eax  #l'id del pilota
    xorl %ebx, %ebx  #spiazzamento per spostarmi nell'output
    xorl %ecx, %ecx  #spiazzamento per spostarmi nell'input
    xorl %edx, %edx  #valore del parametro preso dall'input


    #salvo nello stack l'indirizzo alle stringhe contenenti i nomi dei piloti
    leal pilot_19_str, %eax
    pushl %eax
    
    leal pilot_18_str, %eax
    pushl %eax
    
    leal pilot_17_str, %eax
    pushl %eax
    
    leal pilot_16_str, %eax
    pushl %eax
    
    leal pilot_15_str, %eax
    pushl %eax
    
    leal pilot_14_str, %eax
    pushl %eax
    
    leal pilot_13_str, %eax
    pushl %eax
    
    leal pilot_12_str, %eax
    pushl %eax
    
    leal pilot_11_str, %eax
    pushl %eax
    
    leal pilot_10_str, %eax
    pushl %eax
    
    leal pilot_9_str, %eax
    pushl %eax
    
    leal pilot_8_str, %eax
    pushl %eax
    
    leal pilot_7_str, %eax
    pushl %eax
    
    leal pilot_6_str, %eax
    pushl %eax
    
    leal pilot_5_str, %eax
    pushl %eax
    
    leal pilot_4_str, %eax
    pushl %eax
    
    leal pilot_3_str, %eax
    pushl %eax
    
    leal pilot_2_str, %eax
    pushl %eax
    
    leal pilot_1_str, %eax
    pushl %eax
    
    leal pilot_0_str, %eax
    pushl %eax

    xorl %eax, %eax


    confr_pil: 
        movl $-1, %ecx
        #%ebx prende i piloti salvati nello stack
        popl %ebx 
        confr_pil_1:
            #mi sposto nella stringa di input e nella stringa del pilota candidato
            incl %ecx
            movb (%ebx, %ecx), %dl 
            cmpb $10, (%esi, %ecx)  
            je controlla_zero       
            cmpb $0, %dl            
            je controlla_newline    
            cmpb (%esi, %ecx), %dl  
            jne confr_sbagliato     
            je confr_pil_1          


    controlla_zero: #controllo se la stringa del pilota candidato è finita
        cmpb $0, %dl
        je end_input_name 
        jne confr_sbagliato 

    controlla_newline: #controllo se la prima riga del file di input è finita
        cmpb $10, (%esi, %ecx) 
        je end_input_name 
        jne confr_sbagliato 

    confr_sbagliato: #incremento il contatore dell'ID, controllo che non sia arrivato all'ultimo pilota candidato
        incl %eax 
        cmpl $20, %eax 
        je not_found 
        jmp confr_pil 

    not_found: #il pilota di input non è valido
        xorl %ebx, %ebx 
        xorl %ecx, %ecx
        leal invalid_pilot_str, %esi
        call write 
        jmp exit2 


    end_input_name: #ha trovato il pilota
        movl $19, %edx 
        subl %eax, %edx 
        pulisci_stack: #elimina dallo stack i piloti che non sono stati confrontati
            popl %ebx 
            decl %edx
            cmpl $0, %edx 
            jne pulisci_stack
        


    #IL NOME È VALIDO

    call virgola #richiamo la funzione che trova la virgola nel file di input
    
    xorl %ebx, %ebx 

    find_row: 
        #salvo i valori dei registri utili nello stack per ripristinarli dopo la chiamata alla funzione "atoi"
        pushl %eax
        pushl %ebx
        pushl %edi
        call atoi #richiamo la funzione atoi che converte la stringa dell'ID presente nell'input, alla fine di questa funzione %edx
                  #contiene l'ID dell'input convertito in intero
        popl %edi 
        popl %ebx 
        popl %eax 

        cmpl %eax, %edx #confronto l'ID della riga con l'ID salvato in eax durante il confronto dei candidati
        jne next_row #nel caso non fossero uguali vado alla riga successiva del file di input

        #salvo lo spiazzamento del puntatore dopo l'ID del pilota nella riga del file di input
        pushl %ecx  
        incl %ecx
        pushl %eax 

    comeback: #torno indietro all'inizio della riga
        decl %ecx
        cmpb $10, (%esi, %ecx)
        jne comeback



    #HO TROVATO LA RIGA CON L'ID CHE CERCO

    incl %ecx
    call write_time #richiamo la funzione di scrittura del tempo nel file di output


    rpm: 
        call virgola #scorro fino alla virgola prima dell'ID
        call virgola #scorro fino alla virgola dopo l'ID, il carattere successivo sarà la prima cifra dei giri del motore
        pushl %ebx 
        pushl %edi
        call atoi #edx prende il parametro rpm del file di input
        popl %edi
        popl %ebx
    
                
    
        movl $1, %eax 
    
        #confronto il rpm per capirne il livello (high - medium - low)
        cmpl $5000, %edx
        jle low 
        cmpl $10000, %edx
        jg high 
        jmp medium 
        fine_lhm1:
            movl $44, (%edi, %ebx) 
    
    
        call find_max_rpm #chiamo la funzione che aggiorna lo stack in modo tale che -4(%ebx) contenga il massimo rpm trovato 
    
    
    
    temperatura:
        pushl %ebx 
        pushl %edi
        call atoi #edx prende il parametro rpm del file di input
        popl %edi
        popl %ebx
    
        movl $2, %eax 
    
        #confronto la temperatura per capirne il livello (high - medium - low)
        cmpl $90, %edx  
        jle low 
        cmpl $110, %edx
        jg high 
        jmp medium 
        fine_lhm2:
            movl $44, (%edi, %ebx) 
    
        call find_max_temp #chiamo la funzione che aggiorna lo stack in modo tale che -8(%ebx) contenga la massima temperatura trovata 
    
    
    
    velocita:
        #dato che serviva ecx abbiamo portato fuori l'ID e lo spiazzamento per trovare la virgola appena dopo l'ID e abbiamo rimesso nello stack l'ID
        popl %eax
        popl %ecx
        pushl %eax    
        
        pushl %ebx
        pushl %edi
        call atoi #edx prende il parametro rpm del file di input
        popl %edi
        popl %ebx
    
        movl $3, %eax 
    
        #confronto la velocità per capirne il livello (high - medium - low)
        cmpl $100, %edx 
        jle low 
        cmpl $250, %edx
        jg high 
        jmp medium 
        fine_lhm3:
            movl $10, (%edi, %ebx) 
            incl %ebx
    
        call find_max_vel #chiamo la funzione che aggiorna lo stack in modo tale che -12(%ebx) contenga la massima velocità trovata
    
    
        #MEDIA
        addl $1, -20(%ebp) 
        addl %edx, -16(%ebp) 




    next_row2: #vado alla riga successiva
        incl %ecx
        cmpb $0, (%esi, %ecx) 
        je exit 
        cmpb $10, (%esi, %ecx) 
        jne next_row2


    call virgola
    popl %eax 
    jmp find_row 

    

    next_row: #vado alla riga successiva
        incl %ecx
        cmpb $0, (%esi, %ecx) 
        je exit 
        cmpb $10, (%esi, %ecx)
        jne next_row
    call virgola 
    jmp find_row 


    low: #imposta i registri per la scrittura di low
        pushl %esi
        pushl %ecx
        pushl %edx
        xorl %ecx, %ecx
        incl %ebx
        leal BASSO, %esi #sposto la stringa BASSO in esi
        call write #richiamo la funzione che scrive in output ciò che si trova in esi
        popl %edx
        popl %ecx
        popl %esi

        #confronto eax per capire in quale punto del codice devo tornare
        cmpl $1, %eax
        je fine_lhm1
        cmpl $2, %eax
        je fine_lhm2
        cmpl $3, %eax
        je fine_lhm3

    medium: #imposta i registri per la scrittura di medium
        pushl %esi
        pushl %ecx
        pushl %edx
        xorl %ecx, %ecx
        incl %ebx
        leal MEDIO, %esi #sposto la stringa MEDIO in esi
        call write #richiamo la funzione che scrive in output ciò che si trova in esi
        popl %edx
        popl %ecx
        popl %esi

        #confronto eax per capire in quale punto del codice devo tornare        
        cmpl $1, %eax
        je fine_lhm1
        cmpl $2, %eax
        je fine_lhm2
        cmpl $3, %eax
        je fine_lhm3

    high: #imposta i registri per la scrittura di high
        pushl %esi
        pushl %ecx
        pushl %edx
        xorl %ecx, %ecx
        incl %ebx
        leal ALTO, %esi #sposto la stringa ALTO in esi
        call write #richiamo la funzione che scrive in output ciò che si trova in esi
        popl %edx
        popl %ecx
        popl %esi

        #confronto eax per capire in quale punto del codice devo tornare
        cmpl $1, %eax 
        je fine_lhm1
        cmpl $2, %eax
        je fine_lhm2
        cmpl $3, %eax
        je fine_lhm3


    #HO FINITO DI LEGGERE IL FILE DI INPUT E SCRIVO L'ULTIMA RIGA CON I MASSIMI E LA MEDIA

    exit:
        movl -4(%ebp), %eax 
        call write_end #scrivo sul file di output il massimo rpm
        movl $44, (%edi, %ebx) 
        incl %ebx 
    
        movl -8(%ebp), %eax 
        call write_end #scrivo sul file di output la massima temperatura
        movl $44, (%edi, %ebx) 
        incl %ebx 
    
        movl -12(%ebp), %eax 
        call write_end #scrivo sul file di output la massima velocità
        movl $44, (%edi, %ebx) 
        incl %ebx 
    
        cmpl $0, -20(%ebp) #controllo se il contatore della velocità è a 0 e se lo è significa che non ha mai trovato una riga con l'ID cercato
        je exit0 #se è cosi scrivo come massimi e media degli 0 in output e vado alla fine
    
        pushl %ebx
        xorl %edx, %edx
        movl -16(%ebp), %eax 
        movl -20(%ebp), %ebx 
        divl %ebx #calcolo la media - eax/ebx
        popl %ebx
    
        call write_end #scrivo sul file di output la media della velocità
        movl $10, (%edi, %ebx) 
        incl %ebx 
        movl $0, (%edi, %ebx)
    
        jmp exit2
    
        
    exit0:
    
        movl $48, (%edi, %ebx) 
        incl %ebx 
        movl $10, (%edi, %ebx)
        incl %ebx 
        movl $0, (%edi, %ebx)
    
    
    exit2:
        movl -24(%ebp), %ebx #riporto ebx nelle condizioni iniziali
        movl %ebp, %esp #porto esp alla base dello stack
        popl %ebp #tolgo il base pointer

ret #esco dalla funzione telemetry e ritorno nel main.c




#                                                                 FUNZIONI                                                                   #



atoi: #converte le stringhe del file di input in interi
    incl %ecx 
    movl $10, %edi 
    xorl %edx , %edx
    xorl %eax , %eax
    jmp ripeti2 

    ripeti:
        movb (%esi, %ecx), %dl 
        cmpb $44, %dl 
        je fine_atoi 
        cmpb $10, %dl 
        je fine_atoi 
        cmpb $0, %dl 
        je fine_atoi 
        xorl %edx, %edx 
        mull %edi 
        xorl %edx, %edx
    ripeti2:
        movb (%esi, %ecx), %dl 
        subb $48, %dl 
        addl %edx, %eax 
        incl %ecx 
    jmp ripeti 

fine_atoi:
    movl %eax, %edx #salvo il numero convertito in edx
    ret

##############################################################################################################################################

virgola: #aumenta lo spiazzamento del file di input fino a quando non trova la virgola
    incl %ecx
    cmpb $44, (%esi, %ecx)
    jne virgola

ret

##############################################################################################################################################

find_max_rpm: #trova il massimo del numero dei giri del motore (rpm)
    cmp -4(%ebp), %edx  
    jle fine_max_rpm    
    movl %edx, -4(%ebp) 

fine_max_rpm:
    ret

##############################################################################################################################################

find_max_temp: #trova la temperatura massima
    cmp -8(%ebp), %edx  
    jle fine_max_temp   
    movl %edx, -8(%ebp) 

fine_max_temp:
    ret

##############################################################################################################################################

find_max_vel: #trova la velocità massima
    cmp -12(%ebp), %edx 
    jle fine_max_vel    
    movl %edx, -12(%ebp)

fine_max_vel:
    ret

##############################################################################################################################################

write_time: #scrive il tempo nell'output 
    movb (%esi, %ecx), %dl 
    movb %dl, (%edi, %ebx) 
    cmpb $44, (%esi, %ecx) 
    je fine_write_time
    incl %ecx 
    incl %ebx 
    jmp write_time  

fine_write_time:
    ret

##############################################################################################################################################

#scrive sul file di output ciò a cui punta %esi: il livello (HIGH - LOW - MEDIUM) di rmp, temperatura e velocità, o invalid
 write: 
    movb (%esi, %ecx), %dl 
    movb %dl, (%edi, %ebx) 
    cmpb $0, (%esi, %ecx) 
    je fine_write
    incl %ecx 
    incl %ebx 
    jmp write  

fine_write:
    ret

##############################################################################################################################################

write_end: #scrive il valore che è contenuto in eax sull'ouput
    movl $10, %ecx
    movl $0, %esi  

    ripeti_div:
        xorl %edx, %edx 
        divl %ecx 
        incl %esi
        pushl %edx 
        cmpl $0, %eax 
        jne ripeti_div

    itoa:
        popl %eax 
        addl $48, %eax 
        movl %eax, (%edi, %ebx) 
        incl %ebx 
        decl %esi 
        cmpl $0, %esi  
        jne itoa

ret 
