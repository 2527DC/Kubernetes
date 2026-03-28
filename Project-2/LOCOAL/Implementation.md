# Didnt used the init container for the runing the migration insted used the job to run the migration

- i didnt use the init container for thr migratiion because when it is scalled i think the pod which are scalled tryes to run the migration too which is not necessary

* the replicas are use to make the aplication available

- Implemented the Resource Quota( total resource that can be used by all the pod in the respected namespace ) and limiting range ( sets the minimun and maximun resource limit for the individual pod or container with a namespace )
  --> use case of limiting range
  eg if there is a name space were there is more than one pod which must need the same resourece and for the containers too same resource for all the container in the name space then we can create a saparare limit range kind yml and apply to the perticular namespace

* Question -> Like there will be no resource i the namespace but there will be a deployment wihch is used in the same namepace the what will happen will the pod be in the loop of ceation and tell me how it debuged is there any tooly which help me in the debugging thng like this
  will thepod be in the loop of creation or will i be not able to create the diployment itself
