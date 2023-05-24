/**
* Company     : Plative
* Description : Class to handle Recurssion in trigger
* History     : 
* [28.Jan.2020] Tejkaran - Code Creation 
*/
public class checkRecursiveStatic {
    @TestVisible private static boolean run = true;
    public static boolean runOnce(){
        if(run){
            run=false;
            return true;
        }else{
            return run;
        }
    }
}