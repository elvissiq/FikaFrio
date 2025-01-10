#Include "Protheus.ch"

// ------------------------------------------------------------------
/*/ Rotina MATA920
  Ponto de entrada MTA920I

  Ponto de entrada na rotina Nota Fiscal Manual de Saída (MATA920) 
  para customização da gravação dos dados da Nota Fiscal.

  @author Elvis Siqueira - TOTVS
  @since   09/01/2025
/*/
//-------------------------------------------------------------------
User Function MTA920I()
  
  DBSelectArea("SD2")
  SD2->(dbSetOrder(3))
  IF SD2->(MSSeek(xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ))
    While SD2->(!Eof()) .And. (xFilial("SD2") + SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA) == (xFilial("SF2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA)
      IF SD2->(FieldPos("D2_XLOTECT")) > 0 .And. SD2->(FieldPos("D2_XDTVALI")) > 0
        SD2->D2_LOTECTL := SD2->D2_XLOTECT
        SD2->D2_DTVALID := SD2->D2_XDTVALI
      EndIF 
    SD2->(DBSkip())
    End
  EndIF 

Return
