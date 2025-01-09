#Include "Protheus.ch"

// ------------------------------------------------------------------
/*/ Rotina MATA920
  Ponto de entrada MTA920I

  Ponto de entrada na rotina Nota Fiscal Manual de Saída (MATA920) 
  para customização da gravação dos dados da Nota Fiscal.

  @author Elvis Siqueira - TOTVS
  @since   08/01/2025
/*/
//-------------------------------------------------------------------
User Function MTA920I()
  
  IF SD2->(FieldPos("D2_XLOTECT")) > 0 .And. SD2->(FieldPos("D2_XDTVALI")) > 0
    SD2->D2_LOTECTL := SD2->D2_XLOTECT
    SD2->D2_DTVALID := SD2->D2_XDTVALI
  EndIF 

Return
