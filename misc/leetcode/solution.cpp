#include <iostream>

using namespace std;

// Definition for singly-linked list.
struct Node {

    int data;
    Node* next;

    Node(int val): data(val), next(nullptr) {}


};


// Helper 1: build a linked list from an array
Node* buildList(int arr[], int n) {
    if (n <= 0) return nullptr;          // empty array -> empty list

    Node* head = new Node(arr[0]);       // first node becomes the head
    Node* curr = head;                   // curr points to last created node

    for (int i = 1; i < n; ++i) {
        curr->next = new Node(arr[i]);   // attach next node
        curr = curr->next;               // move to it
    }
    return head;
}


// Helper 2: print the list, so you can see your result
void printList(Node* head) {
    while (head != nullptr) {
        cout << head->data << " ";
        head = head->next;
    }
    cout << endl;
}


// Your solution goes here
Node* reverseKGroup(Node* head, int k, int s) {
    
    //new head = kth element.
    

    //define new head
    

    Node* temp;



   temp = head;                         // 1
   for (int i = 0; i < 1; i++) {

        head = head->next;                  // 2
                                            

    }     

    cout << "debug: " << head->next->data;

    
  
    for (int i = 0; i < 2; i++) {                   // 
        temp = temp->next; //        
        
    }
    //head->next = temp;      

    //head->next = temp; // 

    //this process needs to be done for every multiple of k, the loop must be repeated (nodes_number - nodes_number % k) / k . 
    //   

    /*temp = head->next->next;  // 
    head->next->next = head->next->next->next; // 

    temp->next = temp->next->next;

    head->next->next->next = temp; */

    


 
 
 /*   for (int i = 0; i < 2; i++) {

        temp = head;
        head = head->next;


    }                           */
 
  
  
  
  //  temp = head;
    
   // temp->next = temp->next; 



    temp = head;

    cout << "ugh: " << (temp->data) << endl;
   

    // the for loop must repeat (size - (size%k) ) / k

  /*  int repeat = (s - (s % k)) / k;
    for (int i = 0; i < repeat; i++) {

        temp = head + i*k;                // A grow in a factor of + iK  // 0, 2 
        Node* aux = head + i*k;
        aux = head + (i+1)*k;          // B grow in a factor of + iK  // 0, 2
        



    }
*/

    return head;
}


int main() {

    // Example 1: head = [1,2,3,4,5], k = 2  ->  [2,1,4,3,5]
    int arr[] = {1, 2, 3, 4, 5};
    Node* head1 = buildList(arr, 5);

    // Example 2: same list, k = 3  ->  [3,2,1,4,5]
    //Node* head2 = buildList(arr, 5);

    Node* bruh = reverseKGroup(head1, 2, 5);
    
    cout << "head: " << bruh->data << endl;
    printList(bruh);

    cout << endl;
    return 0;
}
