module question2;
int arr[] = '{1,1,0,1,1,1,1,0,0,0,1};
int count[int];
int temp,max_number;
int max_count=0;
initial begin
    foreach(arr[i])begin
        temp=0;
        for ( int x=i ; x<arr.size() ; x++ ) begin
            if(arr[x]==arr[i]) temp++;
            else break;
        end
        if(temp>count[arr[i]]) begin
            count[arr[i]]= temp;
        end
    end
    foreach(count[i])begin
        if(count[i]>max_count) begin
            max_count=count[i];
            max_number=i;
        end
        else continue;
    end
    $display("Max conseq number : %d -> %d",max_number,max_count); 
end
endmodule