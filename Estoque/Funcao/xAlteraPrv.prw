#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

/*/{Protheus.doc} xAlteraDado
  Carga de dados para alteração
  @type Function de Usuario
  @author TOTVS Recife (Elvis Siqueira)
  @since 21/08/2023
  @version 1.0
  /*/

User Function xAlteraPrv()
  Local aArea := FwGetArea()

  DBSelectArea("SB1")

  DBSelectArea("DA1")
  DA1->(DBGoTop())

  While DA1->(!Eof())
    IF SB1->(MSseek(xFilial("SB1") + DA1->DA1_CODPRO ))
      IF SB1->B1_CONV > 0 .And. DA1->DA1_PRCVEN > 0
        RecLock("DA1",.F.)
          DA1->DA1_PRCVEN := (DA1->DA1_PRCVEN * SB1->B1_CONV)
        DA1->(MSUnlock())
      EndIF
    EndIF
    DA1->(DBSkip())
  End
  FwRestArea(aArea)
Return
