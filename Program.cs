using System;
using System.Security.Cryptography;
using System.Text;

class Program
{
    static void Main()
    {
        // First check to see if the files we want exist.
        System.IO.FileInfo fipsso = new System.IO.FileInfo("/usr/local/lib64/ossl-modules/fips.so");
        if (!fipsso.Exists)
        {
            Console.WriteLine("File not found: " + fipsso.FullName);
        }
        else
        {
            Console.WriteLine("File found: " + fipsso.FullName);
        }

        System.IO.FileInfo fipsmodule = new System.IO.FileInfo("/etc/ssl/fipsmodule.cnf");
        if (!fipsmodule.Exists)
        {
            Console.WriteLine("File not found: " + fipsmodule.FullName);
        }
        else
        {
            Console.WriteLine("File found: " + fipsmodule.FullName);
        }

        string input = "Hello, World!";
        using (MD5 md5 = MD5.Create())
        {
            byte[] inputBytes = Encoding.ASCII.GetBytes(input);
            byte[] hashBytes = md5.ComputeHash(inputBytes);

            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < hashBytes.Length; i++)
            {
                sb.Append(hashBytes[i].ToString("X2"));
            }
            Console.WriteLine("The MD5 hash of " + input + " is: " + sb.ToString());
        }
        Console.WriteLine("Press any key to exit...");
        Console.ReadLine();
    }
}
