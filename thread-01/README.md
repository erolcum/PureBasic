Program, notepad programını açar. Kaç saniye çalıştığını minik pencerede yazar. Minik pencere kapatıldığında notepad programı da kapatılır.<br>
Debug ekranında, Proses Explorer ile de görebileceğiniz thread id (TID) numaraları gösterilir.<br>
Thread, WaitSemaphore da bekler. Her saniye PostEvent ile aşağıdaki ana programa event (olay) yollanır.<br>
Olay oluştuğunda, ana programdaki SignalSemaphore ile thread'in WaitSemaphore satırının altından devam etmesi istenir.<br>

Process Explorer : https://learn.microsoft.com/tr-tr/sysinternals/downloads/process-explorer

![image](https://github.com/user-attachments/assets/527919b3-ef69-4df4-a0c2-b614f112b2bf)

