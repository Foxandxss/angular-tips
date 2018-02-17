+++
title = "Testing the template of an Angular Material Dialog"
date = "2018-02-17T19:20:00+01:00"
tags = ["material"]
categories = []

+++

We love dialogs, we use them for many different things through our applications. Some dialogs may contain some logic but other dialogs are just a mere display of information.

## An information dialog

We are tasked with a simple dialog that will show any kind of information, no extra behavior needed.

The dialog should contain a title and optionally a list of details. Sounds easy, it should look like:

File: `information-dialog.component.ts`
```typescript
import { Component, Inject } from '@angular/core';
import { MAT_DIALOG_DATA, MatDialogRef } from '@angular/material';

@Component({
  templateUrl: './information-dialog.component.html'
})
export class InformationDialogComponent {
  constructor(
    @Inject(MAT_DIALOG_DATA) public data: any,
    public dialogRef: MatDialogRef<InformationDialogComponent>
  ) {}

  close() {
    this.dialogRef.close();
  }
}
```

File: `information-dialog.component.html`
```html
<h2 mat-dialog-title>{{data.title}}</h2>
<mat-dialog-content>
  <ul>
    <li *ngFor="let detail of data.details">
      {{detail}}
    </li>
  </ul>
</mat-dialog-content>
<mat-dialog-actions>
    <button (click)="close()" mat-raised-button>Close</button>
</mat-dialog-actions>
```

It is quite simple and can be used like:

```typescript
matDialog.open(InformationDialogComponent, {
  data: {
    title: 'Some title',
    details: ['A few', 'details']
  }
});
```

## Testing the dialog

The dialog is pretty simple. It has no logic, it just transform some "input" into html. How can we test it?

> Here is a [testing stackblitz](https://stackblitz.com/edit/angular-testing-template) you can use to follow along

Before we dive into any real code here, let's think... This looks pretty much like any other simple component. I can do a:

```typescript
TestBed.create(InformationDialogComponent);
```

Maybe with a fake `MAT_DIALOG_DATA` and then test what I need from its template. That is a rabbit hole and I didn't find a way to do such thing.

The first thing we have to notice here is that the `InformationDialogComponent` won't be used directly in a template, in other words, it is a `EntryComponent`. As far as I know, there is no `entryComponents` array with the `TestingModule` so we need to create a dummy NgModule:

File: `information-dialog.component.spec.ts`
```typescript:
const TEST_DIRECTIVES = [
  InformationDialogComponent
];

@NgModule({
  imports: [MatDialogModule, NoopAnimationsModule],
  exports: TEST_DIRECTIVES,
  declarations: TEST_DIRECTIVES,
  entryComponents: [
    InformationDialogComponent
  ],
})
class DialogTestModule { }
```

Here we import the the needed modules and we register our dialog.

Now, we can create our `TestingModule`:

File: `information-dialog.component.spec.ts`
```typescript:
describe('InformationDialog', () => {
  let dialog: MatDialog;

  beforeEach(() => {
    TestBed.configureTestingModule({
      imports: [ DialogTestModule ]
    });

    dialog = TestBed.get(MatDialog);
  });
});
```

And then our first actual test:

File: `information-dialog.component.spec.ts`
```typescript
it('shows information without details', () => {
  const config = {
    data: {
      title: 'User cannot be saved without an email',
      details: []
    }
  };
  dialog.open(InformationDialogComponent, config);

  // now what???
});
```

How can we make assertions to the template? We don't have a way. We discarded the `.createComponent` option before. What can we do?

Angular Material creates an overlay container to put the dialog in it. We can create a mock of that container and use it to put our new dialog in it.

Let's update our `beforeEach` section again:

File: `information-dialog.component.spec.ts`
```typescript:
let dialog: MatDialog;
let overlayContainerElement: HTMLElement;

beforeEach(() => {
  TestBed.configureTestingModule({
    imports: [ DialogTestModule ],
    providers: [
      { provide: OverlayContainer, useFactory: () => {
        overlayContainerElement = document.createElement('div');
        return { getContainerElement: () => overlayContainerElement };
      }}
    ]
  });

  dialog = TestBed.get(MatDialog);
});
```

Now this says: When Material asks for a `OverlayContainer` create an empty div and return the only portion of the real container we need, in other words, a function that returns our div.

Now, when we open our dialog, it will be hosted in that empty div, and since we have access to it, we can do any assertion. So let's update our test:

File: `information-dialog.component.spec.ts`
```typescript
it('shows information without details', () => {
  const config = {
    data: {
      title: 'User cannot be saved without an email',
      details: []
    }
  };
  dialog.open(InformationDialogComponent, config);

  const h2 = overlayContainerElement.querySelector('#mat-dialog-title-0');
  const button = overlayContainerElement.querySelector('button');

  expect(h2.textContent).toBe('User cannot be saved without an email');
  expect(button.textContent).toBe('Close');
});
```

And that is it, right?

![](/images/posts/dialogtemplate/1.png)

After we spend a while checking and checking what is going on, we discover that our dialog appears in the div, but has no content on it.

Of course! We need to perform change detection. That is easy.

Wait, is it? We don't have any way to trigger the change detection (and I would love to be proven wrong). The simplest way I found to do it, is with a noop component that would just trigger the change detection for us. It is like when a kid ask an adult to buy beer in the store for them.

So at the bottom of the file, with the `NgModule` we create our noop component and we update our array of `TEST_DIRECTIVES`:

File: `information-dialog.component.spec.ts`
```typescript
// Noop component is only a workaround to trigger change detection
@Component({
  template: ''
})
class NoopComponent {}

const TEST_DIRECTIVES = [
  InformationDialogComponent,
  NoopComponent
];
```

Now, we need to create an instance of it:

File: `information-dialog.component.spec.ts`
```typescript:
let dialog: MatDialog;
let overlayContainerElement: HTMLElement;

let noop: ComponentFixture<NoopComponent>;

beforeEach(() => {
  TestBed.configureTestingModule({
    // omitted for brevity
  });

  dialog = TestBed.get(MatDialog);

  noop = TestBed.createComponent(NoopComponent);
});
```

Finally, we can fix our test:

File: `information-dialog.component.spec.ts`
```typescript:
it('shows information without details', () => {
  const config = {
    data: {
      title: 'User cannot be saved without an email',
      details: []
    }
  };
  dialog.open(InformationDialogComponent, config);

  noop.detectChanges(); // Updates the dialog in the overlay

  const h2 = overlayContainerElement.querySelector('#mat-dialog-title-0');
  const button = overlayContainerElement.querySelector('button');

  expect(h2.textContent).toBe('User cannot be saved without an email');
  expect(button.textContent).toBe('Close');
});
```

We just needed to trigger a change detection with our noop component.

Let's throw another test:

File: `information-dialog.component.spec.ts`
```typescript:
it('shows an error message with some details', () => {
  const config = {
    data: {
      title: 'Validation Error - Not Saved',
      details: ['Need an email', 'Username already in use']
    }
  };
  dialog.open(InformationDialogComponent, config);

  noop.detectChanges(); // Updates the dialog in the overlay

  const li = overlayContainerElement.querySelectorAll('li');
  expect(li.item(0).textContent).toContain('Need an email');
  expect(li.item(1).textContent).toContain('Username already in use');
});
```

![](/images/posts/dialogtemplate/2.png)

I'll leave the `close` button test as homework :)

## Conclusion

Creating simple dialogs is an easy task, but testing them can be a bit difficult if we don't know the right tricks. Hopefully this article makes it easier for you.

<iframe src="https://stackblitz.com/edit/testing-material-dialog-template?file=app%2Finformation-dialog.component.spec.ts" width="100%" height="500px">
