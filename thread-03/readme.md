Mk-soft yine sanatsal bir çalışma yapmış 😙 Seri port okuma yazma işleri ayrı bir thread ile yapılmış. PB-Arduino [yazımda](https://erolcum.github.io/led-yakma/) thread kullanmamıştım. Eğer yazdığınız programda başka birçok işler de yapılıyorsa, seri port için thread kullanmak daha iyi olacaktır. Dosyayı kullanmak için kendi programınızın başına XIncludeFile "comport.pbi" yazmanız gerekiyor. CompilerIf #PB_Compiler_IsMainFile - CompilerEndIf bloğu, eğer comport.pbi direk çalıştırılırsa çalışsın demek oluyor. XIncludeFile kullanacaksanız, bu bloğun içini kendi programınıza almanız veya adapte etmeniz gerekiyor.

![image](https://github.com/user-attachments/assets/fdd67988-1e82-4424-9210-a780d5a80380)

