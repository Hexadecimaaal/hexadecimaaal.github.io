Inductive bool :=
| true : bool
| false : bool.

Check true : bool.

Inductive binary_tree :=
| node : binary_tree -> binary_tree -> binary_tree
| leaf : binary_tree.

Check node (node leaf (node leaf leaf)) leaf : binary_tree.

Module mynat.
  
  Inductive nat :=
  | O : nat
  | S : nat -> nat.

  Check S (S O) : nat.

  Check nat : Set.
  Check nat : Type.

  Inductive nat' : Set := O' : nat' | S' : nat' -> nat'.

End mynat.

Inductive prod : Type -> Type -> Type :=
  pair : forall A B, A -> B -> prod A B.

Check prod : Type -> Type -> Type.
Check prod nat binary_tree : Type.

Check pair nat binary_tree 10 leaf : prod nat binary_tree.

Arguments pair {_ _} _ _. (* 自动推断前两个参数 *)
Check pair 233 233 : prod nat nat.

Inductive list : Type -> Type :=
| nil : forall A, list A
| cons : forall A, A -> list A -> list A.

Definition pred (n : nat) :=
  match n with
  | O => O
  | S n' => n'
  end.

Definition pred_pred (n : nat) := pred (pred n).
Definition two := S (S O).
Definition zero := pred_pred two.

Definition pred_pred' := fun n => pred (pred n).

Inductive prod' (A B : Type) :=
  pair' : A -> B -> prod' A B.
  
Inductive list' (A : Type) :=
| nil' : list' A
| cons' : A -> list' A -> list' A.

Definition fst {A B : Type} (p : prod A B) :=
  match p with
  | pair a b => a
  end.
  
Definition snd {A B : Type} (p : prod A B) :=
  match p with
  | pair a b => b
  end.
  
Definition andb (x y : bool) :=
  match x with
  | false => false
  | true => match y with
            | false => false
			| true => true
			end
  end.
  
Notation "a && b" := (andb a b). (* 告诉 Coq 我们将采用 && 的中缀简便记法 *)

Fixpoint plus (a b : nat) :=
match a with
| O => b
| S a' => S (plus a' b)
end.

Notation "a + b" := (plus a b).

Print plus.

Theorem one_is_one :
  1 = 1.
  reflexivity.
Qed.

Theorem O_plus_n : forall n,
    0 + n = n.
  intros.
  simpl.
  reflexivity.
Qed.

Theorem andb_true : forall b,
    b && true = b.
  intros.
  simpl.
  destruct b. {
    simpl.
    reflexivity.
  }
  {
    simpl.
    reflexivity.
  }
Qed.

Print O_plus_n.

Print andb_true.

Inductive even : nat -> Prop :=
| even_O : even 0
| even_SS : forall m, even m -> even (S (S m)).

Arguments even_SS {_} _. (* 自动推断第一个参数 *)

Theorem even_4 : even 4.
  constructor.
  constructor.
  constructor.
Qed.

Print even_4.

Inductive and (A B : Prop) : Prop :=
| conj : A -> B -> and A B.

Arguments conj {_ _} _ _.

Notation "A /\ B" := (and A B) : type_scope.

Theorem even_4_and_6 : even 4 /\ even 6.
  split. {
    apply even_4.
  }
  {
    constructor.
    apply even_4.
  }
Qed.

Print even_4_and_6.

Theorem and_proj1 : forall A B,
  A /\ B -> A.
  intros.
  destruct H.
  apply H.
Qed.

Print and_proj1.

Theorem and_proj1' : forall A B,
  A /\ B -> A.
  Show Proof.
  intros.
  Show Proof.
  destruct H.
  Show Proof.
  assumption.
  Show Proof.
Qed.

Inductive or (A B : Prop) : Prop :=
| or_introl : A -> or A B
| or_intror : B -> or A B.

Arguments or_introl {_ _} _.
Arguments or_intror {_ _} _.

Notation "A \/ B" := (or A B) : type_scope.

Theorem and_or_distr : forall A B C,
    A /\ (B \/ C) ->
    A /\ B \/ A /\ C.
  intros.
  destruct H.
  destruct H0. {
    left.
    apply (conj H H0).
  }
  {
    right.
    apply (conj H H0).
  }
Qed.

Inductive False : Prop :=.

Definition not (A : Prop) : Prop := 
  A -> False.
  
Notation "~ A" := (not A) : type_scope.

Theorem noncontradiction : forall A,
  ~ (A /\ ~ A).
  intros.
  unfold not.
  intros.
  destruct H.
  apply H0.
  assumption.
Qed.

Theorem ex_falso_quodlibet : forall A,
  False -> A.
  intros.
  destruct H.
Qed.

Print ex_falso_quodlibet.

Theorem double_neg : forall A : Prop,
  A -> ~ ~ A.
  intros.
  unfold not.
  intros.
  apply H0.
  assumption.
Qed.



    