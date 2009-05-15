

machines do
  
  zone :"us-east-1b" do
    ami 'ami-e348af8a'               # Alestic Debian 5.0, 32-bit (US)
  end
  zone :"eu-west-1b" do
    ami 'ami-6ecde51a'               # Alestic Debian 5.0, 32-bit (EU)
  end
  
  env :stage do
    role :debian do
      #addresses '11.22.33.44'
    end
  end
  
  
  env :stage do
    role :windows do
      os :win32
      ami 'ami-f9def68d'  # rudy-ami-eu/win2003-32-2009-05-12.manifest.xml
    end
  end
end