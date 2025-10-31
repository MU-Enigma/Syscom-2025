package doublylinkedlist;

public class DoublyLinkedList {
	Node head;
	Node tail;
	int count;
	
	public void add(int data) {
		Node node = new Node(data);
		if(head==null) {                      //checking is this first node or not
			head=tail=node;
			count++;
			return;
		}
		
		tail.next=node;
		node.previous=tail;
		tail=node;
		count++;
	}
	
	public void display() {
		if(head==null) {
			System.out.println("linked list is empty");
		}
		
		Node temp=head;
		while(temp!=null) {
			System.out.print(temp.data+" ");
			temp=temp.next;
		}
		System.out.println();
	}
	
	public void displayBackward() {
		if(head==null) {
			System.out.println("linkedlist is empty");
		}
		Node temp=tail;
		while(temp!=null) {
			System.out.print(temp.data+" ");
			temp=temp.previous;
		}
		System.out.println();
	}
	
	public void add(int position, int data) throws IndexOutOfBoundsException {
		if(position==0) {
			if(head==null) {
				add(data);
				
			}
			Node node = new Node(data);
			node.next=head;
			head.previous=node;
			head=node;
			count++;
		}
		else if(position==count-1) {
			
		}
	}

	
	
	
	
	

}
