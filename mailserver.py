#coding: utf8
#Programma per spedire delle fake mail. Il programma usa 2 file di appoggio: il file config usato per i parametri del server e della porta e il file
#FakeMail da cui legge il from della mail, il destinatario e il contenuto della mail.

#Librerie da usare nel programma
from socket import *
import string
import os.path    #utile per controllare l'esistenza di un file e altre funzioni del S.O.
import time       #Per effettuare operazioni tipo sleep(utile per gestire timeout????)

#################################################################################################
#Definizione variabili
#################################################################################################

file_configurazione = "config.txt"
file_testo = "FakeMail.txt" 
porta = 25
stringa1 = "helo *******.it\n"

##################################################################################################
#Definizione funzioni
##################################################################################################

#Imposto una funzione per il controllo dell'esistenza dei 2 file che mi servono per inviare la mail
#Se uno dei 2 non esiste mi da un mex di errore ed esce dal programma
def controllo_file():
	if os.path.exists(file_configurazione) and os.path.exists(file_testo):
  	  	x=9	
	else:
  		print "File di configurazione mancanti controlla se sono nella stessa directory dov e' contenuto questo programma"
  		exit()


#Socket per la connessione
def connessione(server,mittente,destinatario,porta,mittente_originale):
	s = socket(AF_INET,SOCK_STREAM)
	s.connect((server, porta)) #CONNESSIONE
	st=s.recv(1024)
	print st
	s.send(stringa1)   #HELO
	st=s.recv(1024)
	print st
	s.send(mittente)  #MAIL FROM 
	st=s.recv(1024)    
	print st 
	s.send(destinatario)   #RCPT TO
	st=s.recv(1024)
	print st
	s.send("data\n")
	print("DATA\n")
        st=s.recv(1024)
	print st
	testo= "To: \n"# %mittente_originale
	s.send(testo)
	st=s.recv(1024)
	print st
	st = fakemail.readline()
	testo = "Subject: %s \n" %st
	s.send(testo)
	print testo
	while 1:
		testo = fakemail.readline()
		if testo == "":
		   break
		s.send(testo)
		print testo
	s.send("\n") #Lascio una riga vuota e poi un . ad indicare la fine della mail
	s.send(".\n")
	st = s.recv(1024)
	print st
	exit()
	

####################################################################################################
#Programma Main
####################################################################################################

#Open file config and FakeMail
#N.B. il file di configurazione è config.txt

config = open(file_configurazione,'r')
fakemail = open(file_testo,'r')

controllo_file()

#Leggo i 3 parametri che mi servono
server = config.readline()
mittente = config.readline()
destinatario = config.readline()

mittente =  mittente[:-1]
destinatario = destinatario [:-1]
dest = "rcpt to: <%s> \n" %destinatario
mit = "mail from: <%s> \n" %mittente

config.close()
#Chiudo il file, i parametri li ho letti ora non mi dovrebbe più servire

print server
print mit
print dest
connessione(server,mit,dest,porta,destinatario)
exit()





