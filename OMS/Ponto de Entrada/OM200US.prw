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
  Local nId     := 0
  Local aRotina := ParamIxb

  If Len(aRotina) == 7
     For nId := 1 To Len(aRotina)
         If AllTrim(aRotina[nId][01]) == "Carregamento"
            aAdd(aRotina[nId][02],{"Importar FUSION","U_FFOMSM01()", 0, 1,0,NIL})   
            aAdd(aRotina[nId][02],{"Log Integração" ,"U_FFOMSC01()", 0, 1,0,NIL})   

            exit   
         EndIf
     Next
  EndIf
Return aRotina
