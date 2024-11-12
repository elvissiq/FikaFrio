#Include "protheus.ch"
#Include "parmtype.ch"

// ----------------------------------------------------------
/*/ Rotina OMSA200
  Ponto de entrada OM200US

   Na Montagem da Carga para acrescentar rotina no menu.
    
   Implementado para:
     - Adicionar rotinas customizadas no menu.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//--------------------------------------------------------
User Function OM200US()
  Local aRotina := ParamIxb
  Local nPos    := aScan(aRotina,{|x| x[01] == "Carregamento"})

  If nPos > 0
     If ValType(aRotina[nPos][02]) == "A"
        aAdd(aRotina[nPos][02],{"Importar FUSION","U_FFOMSM02()",0,1,0,NIL})   
        aAdd(aRotina[nPos][02],{"Log Integração" ,"U_FFOMSC01()",0,1,0,NIL})   
     EndIf
  EndIf
Return aRotina
