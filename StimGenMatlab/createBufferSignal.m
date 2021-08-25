function newBufferSignal=createBufferSignal(pulseInSingleChannel,currentBufferSignal)


    rowPulseInSingleChannel= size(pulseInSingleChannel,1);
    rowoldBuffer= size(currentBufferSignal,1);
    
if(isempty(currentBufferSignal))
    newBufferSignal=pulseInSingleChannel;
else
    newBufferSignal=uint32(zeros(rowPulseInSingleChannel+rowoldBuffer,9)); %Nowy bufor ma rozmiar maksymalnie starego bufora plus nowy sygna³, moze byæ mniejszy
    newBufferSignal(1:rowoldBuffer,:)=currentBufferSignal; % na pocz¹tku do nowego przepisuje ze starego
  for i=1:rowPulseInSingleChannel 

      
 
   k=find(newBufferSignal(:,1)==(pulseInSingleChannel(i,1))); %Szukamy, czy w buforze s¹ pola o tym samym indeksie ramki


    if isempty(k) % nie ma

      
        newBufferSignal(rowoldBuffer+i,:)=pulseInSingleChannel(i,:);

    else % jest
        
            maximum=max(k);
            minumum=min(k);  

        quest=newBufferSignal(k,2);  % !!!!!!!!
        l=find(quest==pulseInSingleChannel(i,2)); % sprawdzam czy wœród znalezionych w buforze s¹ takie, które maj¹ które maj¹ taka sama wartoœæ w obrebie ramki                                
      
        if isempty(l) % nie ma
         %spoœród tych bloków o tym samym numerze ramki ten o najmniejszym indeksie
         %Patrzymy, czy pole maski w tym bloku wartoœæ wiêksza od 255 (od³¹czanie niestymulowanych kana³ów)
         %Potem patrzymy, czy w naszym nowym bloku jest wiêksza od 255
         %Jeœli co najmniej jedno z tych dwóch jest prawd¹, to wsadzamy nowy blok na odpowiednie miejsce
         %ORAZ dla bloku o najmniejszym indeksie spoœród tych o tej samej ramce dodajemy 256 do wartoœci pola masek.   
            if newBufferSignal(minumum,3)>255
                pulseInSingleChannel(i,3)=pulseInSingleChannel(i,3)+256;
                newBufferSignal=[newBufferSignal(1:maximum,:);pulseInSingleChannel(i,:);newBufferSignal( maximum+1:end,:)];

            else 
                if pulseInSingleChannel(i,3)>255
                    newBufferSignal(maximum:minumum,3)=newBufferSignal(maximum:minumum,3)+256;
                    newBufferSignal=[newBufferSignal(1:maximum,:);pulseInSingleChannel(i,:);newBufferSignal( maximum+1:end,:)];
                else
                    newBufferSignal=[newBufferSignal(1:maximum,:);pulseInSingleChannel(i,:);newBufferSignal( maximum+1:end,:)];
                end
            end
            
        else %s¹, dodaje odpowiednie 6 wartoœci U32
           %l(i)=l(i)+k(1)-1;
           
           newBufferSignal(k(l),3:9)=pulseInSingleChannel(i,3:9)+newBufferSignal(k(l),3:9);

           %newBuffer(l(i),3:end)=pulseInSingleChannel(i,3:end)+newBuffer(l(i),3:end);
        end
    end
  end
    
  
%newBuffer=newBuffer(newBuffer(:,1)~=0&newBuffer(:,2)~=0&newBuffer(:,3)~=0&newBuffer(:,5)~=0&newBuffer(:,7)~=0&newBuffer(:,9)~=0,:); 
newBufferSignal=newBufferSignal(newBufferSignal(:,1)~=0,:); % na razie szukamy niezmodyfikowanych wierszy w buforze. Docelowo mo¿na inaczej - na bie¿¹co zapamietywac ktore wiersze bufora sa modyfikowane i szukac najwiekszego indeksu sposrod zmodyfikowanych. Wtedy na sam koniec trzeba wyrzucic wszystkie wiersze starsze niz ten indeks.
   %usuwam zbêdne zera
end
end