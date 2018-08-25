#define PERL_NO_GET_CONTEXT
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include "ppport.h"

/*#include "multicall.h"*/

#define iParent(i)      (((i)-1) / 2)
#define iLeftChild(i)   ((2*(i)) + 1)
#define iRightChild(i)  ((2*(i)) + 2)

int sift_up(SV **a, ssize_t start, ssize_t end) {
     /*start represents the limit of how far up the heap to sift.
       end is the node to sift up. */
    ssize_t child = end;
    SV *tmpsv = NULL;
    int child_is_magic;
    int swapped = 0;
    SV *tmp;
    SvGETMAGIC(a[child]);
    child_is_magic= SvAMAGIC(a[child]);

    while (child > start) {
        ssize_t parent = iParent(child);
        int parent_is_magic;
        SvGETMAGIC(a[parent]);
        parent_is_magic= SvAMAGIC(a[parent]);
        if ( child_is_magic || parent_is_magic ) {
            tmpsv = amagic_call(a[child], a[parent], gt_amg, 0);
            if (!tmpsv || !SvTRUE(tmpsv) ) {
                 return swapped;
            }
        }
        else
        if ( Perl_do_ncmp(aTHX_ a[child], a[parent]) <= 0 ) {
            return swapped;
        }
        tmp= a[parent];
        a[parent]= a[child];
        a[child]= tmp;
        child = parent; /* repeat to continue sifting up the parent now */
        child_is_magic= parent_is_magic;
        swapped++;
    }
    return swapped;
}

/*Repair the heap whose root element is at index 'start', assuming the heaps rooted at its children are valid*/
int sift_down(SV **a, ssize_t start, ssize_t end) {
    ssize_t root = start;
    int root_is_magic = SvAMAGIC(a[root]);
    int swapped = 0;

    while (iLeftChild(root) <= end) {       /* While the root has at least one child */
        ssize_t child = iLeftChild(root);       /* Left child of root */
        int child_is_magic = SvAMAGIC(a[child]);
        ssize_t swap = root;                    /* Keeps track of child to swap with */
        int swap_is_magic = root_is_magic;
        SV *tmpsv = NULL;

        /* if the focus (swap/root) is smaller than the child, then swap with the child */
        if ( (child_is_magic || swap_is_magic) ) {
            tmpsv = amagic_call(a[child], a[swap], gt_amg, 0);
            if (tmpsv && SvTRUE(tmpsv)) {
                swap = child;
                swap_is_magic = child_is_magic;
            }
        }
        else if ( Perl_do_ncmp(aTHX_ a[child], a[swap]) > 0 ) {
            swap = child;
            swap_is_magic = child_is_magic;
        }
        /* If there is a right child and that child is greater */
        if (child+1 <= end) {
            child_is_magic = SvAMAGIC(a[child+1]);
            if ( (child_is_magic || swap_is_magic) ) {
                tmpsv = amagic_call(a[child+1], a[swap], gt_amg, 0);
                if (tmpsv && SvTRUE(tmpsv)) {
                    swap = child + 1;
                    swap_is_magic = child_is_magic;
                }
            }
            else if ( Perl_do_ncmp(aTHX_ a[child+1], a[swap]) > 0 ) {
                swap = child + 1;
                swap_is_magic = child_is_magic;
            }
        }
        if (swap == root) {
            /*The root holds the largest element. Since we assume the heaps rooted at the
             children are valid, this means that we are done.*/
            return swapped;
        } else {
            SV *tmp= a[root];
            a[root]= a[swap];
            a[swap]= tmp;
            root = swap;     /*repeat to continue sifting down the child now*/
            root_is_magic = swap_is_magic;
            swapped++;
        }
    }
    return swapped;
}

/* this is O(N log N) */
void heapify_with_sift_up(SV **a, ssize_t count) {
    ssize_t end = 1; /* end is assigned the index of the first (left) child of the root */

    while (end < count) {
        /*sift up the node at index end to the proper place such that all nodes above
          the end index are in heap order */
        (void)sift_up(a, 0, end);
        end++;
    }
    /* after sifting up the last node all nodes are in heap order */
}

/* this is O(N) */
void heapify_with_sift_down(SV **a, ssize_t count) {
    /*start is assigned the index in 'a' of the last parent node
      the last element in a 0-based array is at index count-1; find the parent of that element */
    ssize_t start = iParent(count-1);

    while (start >= 0) {
        /* sift down the node at index 'start' to the proper place such that all nodes below
         the start index are in heap order */
        (void)sift_down(a, start, count - 1);
        /* go to the next parent node */
        start--;
    }
    /* after sifting down the root all nodes/elements are in heap order */
}

MODULE = Algorithm::Heapify::XS		PACKAGE = Algorithm::Heapify::XS		

void
heapify(av)
    AV *av
PROTOTYPE: \@
PPCODE:
    int count= av_top_index(av)+1;
    if ( count ) {
        /* using sift_up while I debug overloading */
        heapify_with_sift_up(AvARRAY(av),count);
        ST(0)= AvARRAY(av)[0];
        XSRETURN(1);
    }
    else {
        XSRETURN(0);
    }

void
heap_shift(av)
    AV *av
PROTOTYPE: \@
PPCODE:
    int top= av_top_index(av);
    int count= top+1;
    if (count) {
        SV *tmp= AvARRAY(av)[0];
        AvARRAY(av)[0]= AvARRAY(av)[top];
        AvARRAY(av)[top]= tmp;
        ST(0)= av_pop(av);
        if (count > 2)
            sift_down(AvARRAY(av),0,top-1);
        XSRETURN(1);
    }
    else {
        XSRETURN(0);
    }

void
heap_adjust_top(av)
    AV *av
PROTOTYPE: \@
PPCODE:
    int top= av_top_index(av);
    int count= top + 1;
    if ( count ) {
        (void)sift_down(AvARRAY(av),0,top);
        ST(0)= AvARRAY(av)[0];
        XSRETURN(1);
    } else {
        XSRETURN(0);
    }

void
heap_adjust_item(av,idx)
    AV *av
    int idx = 0;
PROTOTYPE: \@;$
PPCODE:
    int top= av_top_index(av);
    int count= top + 1;
    if ( count ) {
        if (!idx || !sift_up(AvARRAY(av),0,idx))
            (void)sift_down(AvARRAY(av),idx,top);
        ST(0)= AvARRAY(av)[0];
        XSRETURN(1);
    } else {
        XSRETURN(0);
    }

