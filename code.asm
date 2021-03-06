;BLM2008.1 MIKROISLEMCILER FINAL PROJE ODEVI
;05.07.2020
;SUHENDA HILAL ETO 
;170418016


      .MODEL SMALL
      .DATA
GMSG  DB  'TIC TAC TOE OYUNU',0DH,0AH
      DB  'KULLANICI X, BILGISAYAR O',0DH,0AH,0DH,0AH,'$'
BOARD DB  '123456789'
BTXT  DB  0DH,0AH
      DB  '  |   |  ',0DH,0AH   ;tahta tanimladik
      DB  '---------',0DH,0AH
      DB  '  |   |  ',0DH,0AH
      DB  '---------',0DH,0AH
      DB  '  |   |  ',0DH,0AH,0DH,0AH,'$'
BPOS  DB  2,6,10,24,28,32,46,50,54
PMSG  DB  'SIRA SIZDE 0-9 ARASINDA BIR SAYI GIR: $'
PIM1  DB  0DH,0AH,'YANLIS HAREKET LUTFEN TEKRAR DENE',0DH,0AH,'$'
PIM2  DB  0DH,0AH,'SECTIGIN YER DOLU,LUTFEN TEKRAR DENE',0DH,0AH,'$'
CMSG  DB  'BILGISAYAR OYNUYOR.. $'
CRLF  DB  0DH,0AH,'$'
WINS  DW  1,2,3, 4,5,6, 7,8,9                ;satir olarak kazanma ihtimali
      DW  1,4,7, 2,5,8, 3,6,9                ;sutun olarak kazanma ihtimali
      DW  1,5,9, 3,5,7                       ;capraz kazanma ihtimali
XWIN  DB  'X OYUNU KAZANDI,TEBRIKLER!',0DH,0AH,'$'
OWIN  DB  'O OYUNU KAZANDI,KAYBETTIN!',0DH,0AH,'$'
MTIE  DB  'OYUN BERABERE BITTI',0DH,0AH,'$'
       
       .CODE
       .STARTUP
       LEA   DX,GMSG  ;baslangic icin bir pointer tanimladik
       MOV   AH,9     ;stringi gosterdik
       INT   21H
       CALL  SHOWBRD  ;tahtayi gosterdik
NEXT:  CALL  PMOVE    ;kullanici hareketini aldik
       CALL  SHOWBRD  ;tahtayi gosterdik
       CALL  CHECK    ;kazanip kazanmadigini kontrol ettik
       JZ    EXIT
       CALL  CMOVE    ;bilgisayar bos bir alana oynadi
       CALL  SHOWBRD  ;tahtayi gosterdik
       CALL  CHECK    ;kazanip kazanmadigini kontrol ettik
       JZ    EXIT
       JMP   NEXT     ;oyuna devam
EXIT:  HLT

SHOWBRD PROC  NEAR
        MOV   CX,9             ;bir loop tanimladik
        SUB   SI,SI            ;baslangic pointeri tanimladik
LBC:    MOV   AL,BPOS[SI]      ;tahtadaki pozisyonu aldik
        CBW                    ;sembole cevirdik
        MOV   DI,AX            ;pointeri tahtanin stringine tanimladik
        MOV   AL,BOARD[SI]     ;oyuncunun sembolunu aldik
        MOV   BTXT[DI],AL      ;pointeri tahtanin stringine yerlestirdik
        INC   SI               ;pointer tanimladik
        LOOP  LBC              ;her dokuz kare icin tekrarladik
        LEA   DX,BTXT          ;pointeri tahtanin stringine tanimladik
        MOV   AH,9             ;string fonksiyonunu gosterdik
        INT   21H              ;DOS 
        RET
SHOWBRD ENDP

PMOVE  PROC NEAR
       LEA  DX,PMSG         ;oyuncu stringi icin bir pointer tanimladik
       MOV  AH,9            ;string fonksiyonunu gosterdik
       INT  21H             ;DOS 
       MOV  AH,1            ;klavyeden girisi okuduk
       INT  21H             ;DOS 
       CMP  AL,'1'          ;sayi girip girilmedigini karsilastirdik
       JC   BPM
       CMP  AL,'9'+1
       JNC  BPM
       SUB  AL,31H          ;ASCII sapmasini duzelttik
       CBW                  ;kelimeye cevirdik
       MOV  SI,AX           ;baslangic pointeri tanimladik
       MOV  AL,BOARD[SI]    ;tahtanin sembolunu kontrol ettik
       CMP  AL,'X'          ;tahtada o yer bos mu dolu mu diye baktik
       JZ   PSO
       CMP  AL,'O'
       JZ   PSO
       MOV  BOARD[SI],'X'   ;oyuncu hareketini sakladik
       LEA  DX,CRLF         ;yeni satir icin pointer tanimladik
       MOV  AH,9            ;string fonksiyonunu gosterdik
       INT  21H             ;DOS 
       RET
BPM:   LEA  DX,PIM1         ;illegal string icin pointer tanimladik
STP:   MOV  AH,9            ;string fonksiyonunu gosterdik
       INT  21H             ;DOS 
       JMP  PMOVE           ;oyuncuya ikinci bir sans tanima
PSO:   LEA  DX,PIM2         ;dolu olan yer stringi icin yeni bir pointer tanimladik
       JMP  STP             ;error mesaji
       RET
PMOVE  ENDP

CMOVE  PROC NEAR
       SUB  SI,SI           ;baslangic pointerini sifirladik
NCM:   MOV  AL,BOARD[SI]    ;tahtanin sembolune baktik
       CMP  AL,'X'          ;tahtada o yer bos mu dolu mu diye baktik
       JZ   STN
       CMP  AL,'O'
       JZ   STN
       MOV  BOARD[SI],'O'   ;bilgisayar hamlesini tuttuk
       MOV  AX,SI           
       PUSH AX
       LEA  DX,CMSG         ;secim stringi icin pointer tanimladik
       MOV  AH,9            ;string fonksiyonunu gosterdik
       INT  21H             ;DOS 
       POP  DX              ;hamleyi getirdik
       ADD  DL,31H          ;ASCII sapmasini ekledik
       MOV  AH,2            ;karakter fonksiyonunu gosterdik
       INT  21H             ;DOS 
       LEA  DX,CRLF         ;yeni satir icin pointer tanimladik
       MOV  AH,9            ;string fonksiyonunu gosterdik
       INT  21H             ;DOS 
       RET
STN:   INC  SI              ;sonraki kutucuga ilerle
       JMP  NCM             ;sonraki kutucugu kontrol et
CMOVE  ENDP

CHECK  PROC NEAR
       SUB  SI,SI             ;baslangic pointerini sifirladik
       MOV  CX,8              ;loop sayici kurduk
CAT:   MOV  DI,WINS[SI]       ;tahtanin birinci pozisyonunu al
       MOV  AH,BOARD[DI-1]    ;sembolunu al
       MOV  DI,WINS[SI+2]     ;tahtanin ikinci pozisyonunu al
       MOV  BL,BOARD[DI-1]    ;sembolunu al
       MOV  DI,WINS[SI+4]     ;tahtanin ucuncu pozisyonunu al
       MOV  BH,BOARD[DI-1]    ;sembolunu al
       ADD  SI,6              ;sonraki pozisyonlara ilerle
       CMP  AH,BL             ;aldigimiz bu uc sembol ayni mi kontrol ediyoruz
       JNZ  NMA
       CMP  AH,BH
       JNZ  NMA
       CMP  AH,'X'            ;uc sembol ayniysa bunlar X'i iceeriyor mu kontrol ediyoruz
       JNZ  WIO
       LEA  DX,XWIN           ;oyuncu kazandi sringi icin pointer tanimladik
       JMP  EXC               ;islem stringi
WIO:   LEA  DX,OWIN           ;bilgisayar kazandi stringi icin pointer tanimladik
       JMP  EXC               ;islem stringi
NMA:   LOOP CAT               ;bu ucu eslesmiyor baska gruba bakicaz
       SUB  SI,SI             ;baslangic pointerini sifirliyoruz
CFB:   MOV  AL,BOARD[SI]      ;tahtanin sembolunu aldik
       CMP  AL,'X'            ;X sembolu mu diye kontrol ediyoruz
       JZ   IAH
       CMP  AL,'O'            ;is symbol O?
       JZ   IAH
       RET                    ;beraberlik degilse hala
IAH:   INC  SI                ;diger pozisyona ilerle
       LOOP CFB               ;diger tahta sembollerini kontrol et
       LEA  DX,MTIE           ;beraberlik mesaji icin pointer tanimladik
EXC:   MOV  AH,9              ;string fonksiyonunu gosterdik
       INT  21H               ;DOS call
       SUB  AL,AL             
       RET
CHECK  ENDP

       END