******** LE COOPER (BYE SUPER LOCK)*****
*				       *
*   Merci d'expliquer vos source       *
*	  IN FRENCH PLEASE	       *
*	Source : lock/hbl4.s		*
****************************************
* Programme ok - 11/02/90
intena equ $9a
dmacon equ $96
color00 equ $180

cop1lc equ $80
cop2lc equ $84
copjmp1 equ $88
copjmp2 equ $8a

ciaapra equ $bfe001 * Ya pas que la souris qu'on peut tester
		    * $39 pour la touche -->  Ctrl
		    * les autres vas lire Le livre du language machine

openlibrary equ -30-522
forbid equ -30-102
permit equ -30-108
allocmem equ -30-168
freemem equ -30-180

startlist equ 38

execbase equ 4
chip equ 2

start:
	move.l	execbase,a6	* Reserve l'espace memmoire
	move	#clsize,d0	* Pour la copper-list
	move	#chip,d1
	jsr	allocmem(a6)
	move.l	d0,cladr
	beq 	fin
	
	move.l	$6c,sav_vbl	* Pour usage future
	
	bsr	const_copper	* Construction de la copper-list

	lea	clstart,a0	* On copie la copper-list
	move.l	cladr,a1
	move	#clsize-1,d0
clcopy:
	move.b	(a0)+,(a1)+
	dbf	d0,clcopy
		
	jsr	forbid(a6)	* Initialise le copper
	lea	$dff000,a5
	move.w	#$03a0,dmacon(a5)
	move.l	#clstart,cop1lc(a5)
	clr.w	copjmp1(a5)
	move.w	#$8280,dmacon(a5)
	move.l	#sync,$6c
	bra	wait2
wait:				* Faudra chercher autre chose
sync				* Pour la VBL
	move.w	#1,v_sync	
	move.l	sav_vbl,a0
	jmp	(a0)		* Car je fais un saut a la routine
				* Rom... pas bon ca..... 
	rte			* Haha y sert a rien le malheureux
wait2	
	cmp.w	#1,v_sync	* Synchro pas au point ca merde
	bne	wait_sync
	bsr	hbl		* On recopie la copper-list
	bsr	hbl_bleu	* On y met la barre bleu
	sub.w	#1,v_sync
wait_sync
	btst	#6,ciaapra	* Attente bouton gauche souris
	bne.s	wait2		* si PUSH alors BYE BYE

fini	move.l	sav_vbl,$6c	* a usage future
	
	move.l	#grname,a1	* On réintialise tout
	clr.l   d0		* (On regresse.. faire appel aux library
	jsr	openlibrary(a6)	* j'aurai vraiment tout vu..........
	move.l	d0,a4
	move.l	startlist(a4),cop1lc(a5) * Un vrai bordel...
	clr.w	copjmp1(a5)		* On manque d'info sur copper
	move.w	#$83e0,dmacon(a5)
	jsr	permit(a6)

fin:
	clr.l	d0
	rts		        * A LA PROCHAINE......			


******** RRRRhhhhhhaaaaaa le plus marrant.....
* Construction d'une copper-list:
* 
*  MADE BY LOCK RRHHHAAAA THE BEST.....
**********************************************	
const_copper:
	lea	clstart,a0	* A0 pointe sur la copper-list
	lea	table_deg,a1	* A1        sur notre table de couleur
	move.b	#1,d5		* Bit 0 mis a 1 pour le Wait
	move.w	#$36,d0		* Je debute a la 54eme ligne (pourquoi pas)
cree_deg:
	move.b	d0,(a0)+	* Numero de la ligne(Y) dans Copper-list
	move.b	d5,(a0)+	* Attente horizontal(X) dans Copper-list		
	move.w	#$fffe,(a0)+	* Pour le Wait tous les bits masqués
	move.w	#$180,(a0)+	* Couleur de fond via  Copper-list
	move.w	(a1),(a0)+	* Couleur du raster via Copper-list
* Wait
	add.b	#110,d5		* Wait 80 pour affichage debut de barre
	move.b	d0,(a0)+	* Numero de la ligne(Y) dans Copper-list
	move.b	d5,(a0)+	* Attente horizontal(X) dans Copper-list		
	move.w	#$fffe,(a0)+	* Pour le Wait tous les bits masqués
	move.w	#$180,(a0)+	* Couleur de fond via  Copper-list
	move.w	(a1),(a0)+	* Couleur du raster via Copper-list
* Wait
	add.b	#60,d5		* Wait 60 pour longueur de barre
	move.b	d0,(a0)+	* Numero de la ligne(Y) dans Copper-list
	move.b	d5,(a0)+	* Attente horizontal(X) dans Copper-list		
	move.w	#$fffe,(a0)+	* Pour le Wait tous les bits masqués
	move.w	#$180,(a0)+	* Couleur de fond via  Copper-list
	move.w	(a1)+,(a0)+	* Couleur du raster via Copper-list
	sub.b	#170,d5		* On remet normal pour prochaine ligne

	add.w	#1,d0		* Ligne suivant
	cmp.w	#$f0,d0		* 240eme ligne? non! recommence 
	bmi cree_deg		* Oui! alors on a fini:
	move.l	#$fffffffe,(a0)+ * Pour la fin de la Copper-list  	
	rts

********** Recopie toutes les couleurs de la copper-list
*	   aprés le passage de la barre bleu
****              pas trés bon hein!!!!
hbl:
	lea	clstart,a0	* Y'aurai bien une autre methode
	lea	table_deg,a1	* mais chiante a programmee
	move.l	#end_col,d0	* ( copier dans un buffer les couleurs
	move.l	#table_deg,d1	* derriere la barre puis les reafficher)
	sub.l	d1,d0
	divu	#2,d0
 			* pour diminution de la barre
encore	move.w	(a1),6(a0)
	add.b	#2,9(a0)	* Wait debut +2
	move.w	(a1),14(a0)
	sub.b	#2,17(a0)	* Wait fin   -2
	move.w	(a1)+,22(a0)
	lea	24(a0),a0	* +24 pour la ligne suivante
	dbf	d0,encore	* car 3 wait par ligne 3*8 24
	rts

******** Allez au tour de la barre bleu maintenant....
hbl_bleu	
	tst.w	flag	* Drapeau pour savoir si on monte ou descend
	beq	descend * 0 alors on descent
	
monte:			* 1 on monte
	cmp.w	#2,pos	* Position minimale autorisée
	bpl	cont
	eor	#1,flag * <=2 on inverse le flag
	rts
cont	lea	bleu,a3 * A3 pointe sur la table de couleur de la barre
	sub.w	#2,pos	* on remonte
	move	pos,d0
	mulu	#24,d0	* La couleur dans la copper-list est tous les 24 octets
	bra	vas_y	* On met la barre 'in Copper-list'

descend:
	cmp.w	#170,pos 	* 170eme ligne = maximun autorisé
	bmi	cont2	
	eor	#1,flag		* Inversion du drapeau 
	rts	
cont2	lea	bleu,a3		* Voir explication de cont 
	add.w	#2,pos
	move	pos,d0
	mulu	#24,d0		* Chaque couleur de la copper-list se
				* trouve toute les 24 octets
				* car il y a 3 Wait pour la barre


vas_y	
	lea	clstart+8,a1	* On pointe sur la copper-list
	move.w	#12,d1		* 13 teintes pour la barre
	eor.w 	#26,lui		* Pour inversion des barres effet
	add.w	lui,a3		* de rouleau (j'ai pas la bonne synchro)
vas_y2	
	move.w	(a3)+,6(a1,d0.w) * Mets la banane....

	lea	24(a1),a1	* Plus 8 pour la prochaine couleur
	dbf	d1,vas_y2	* t'as pas fini 
	rts			* Ouf t'es longué.....

flag	dc.w	0		* Drapeau pour Haut ou Bas
pos	dc.w	2		* Ta position de la barre

hbb	dc.w 0

v_sync	dc.w    0		* Y'en faut une non?...
	
sav_vbl	dc.l 0			* Comment la remettre si on la pas sauvée

cladr:	dc.l 0
grname:	dc.b "graphics.library",0 *RRRhaaa que c'est nul
	even
	dc.w  200,00
lui	dc.w  0	 		* Mais non pas TOI
table_deg	
		dc.w    1,2,3,4,5,6,7,8,9,$a,$b,$c,$d,$e,$f
		dc.w    $101,$202,$303,$404,$505,$606,$707,$808,$909,$a0a,$b0b,$c0c,$d0d,$e0e,$f0f
		dc.w	$100,$200,$300,$400,$500,$600,$700,$800,$900,$a00,$b00,$c00,$d00,$e00,$f00
		dc.w	$110,$220,$330,$440,$550,$660,$770,$880,$990,$aa0,$bb0,$cc0,$dd0,$ee0,$ff0
		dc.w	$10,$20,$30,$40,$50,$60,$70,$80,$90,$a0,$b0,$c0,$d0,$e0,$f0
		dc.w	$123,$234,$345,$456,$567,$789,$89a,$9ab,$abc,$bcd,$def,$eef,$eff,$fff
		dc.w	$100,$201,$312,$423,$534,$645,$756,$867,$978,$a89,$b9a,$dab,$ebd,$fde
		dcb.w   100,00
end_col
bleu		dc.w	$033,$400,$055,$600,$077,$800,$099
		dc.w	$800,$077,$600,$055,$400,$033

rouge		dc.w	$300,$44,$500,$66,$700,$88,$900
		dc.w	$88,$700,$66,$500,$44,$300

clstart:
	ds.l  3000
clend:
clsize equ clend-clstart

