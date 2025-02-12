global class BatchVerificaContasFilhas implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful, Schedulable {
	
	String query;
	List<Account> listAccount;
	
	global BatchVerificaContasFilhas() {

     listAccount = new List<Account>();
    
    }
	global Database.QueryLocator start(Database.BatchableContext BC) {	
     
		  query = 'SELECT Id, Name, ParentId FROM Account';

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		listAccount = (List<Account>) scope;
          for(Account conta: listAccount){
              conta.Qtd_de_Contas_filhas__c	= getQuantidadeContaFilha(conta);
          }
          TriggerHandlerConta.ignoreTrigger = true;
          Toolkit.ignoraRegraValidacao(true);
          Database.update(listAccount, false);
          TriggerHandlerConta.ignoreTrigger = false;
          Toolkit.ignoraRegraValidacao(false);
		    
		   
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}

	global void execute(SchedulableContext sc) {
		Database.executeBatch( new BatchVerificaContasFilhas(), 10 );
	}

    /*


    */
    private Integer getQuantidadeContaFilha(Account conta){
        integer qtdContas;
       
        List<AggregateResult> ars;
        ars = [SELECT COUNT(Id) total
               FROM Account 
               WHERE ParentId = : Conta.Id
               GROUP BY ParentId];

        if (ars.size() > 0 && ars.get(0).get('total') != null){
            qtdContas = (Integer) ars.get(0).get('total');
        }
        return qtdContas;   
    }



}