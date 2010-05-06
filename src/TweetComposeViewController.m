/*
 * (C) Copyright 2010, Stefan Arentz, Arentz Consulting Inc.
 *
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements.  See the NOTICE file distributed with
 * this work for additional information regarding copyright ownership.
 * The ASF licenses this file to You under the Apache License, Version 2.0
 * (the "License"); you may not use this file except in compliance with
 * the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "TwitterConsumer.h"
#import "TwitterToken.h"
#import "TwitterTweetPoster.h"
#import "TweetComposeViewController.h"

@implementation TweetComposeViewController

@synthesize delegate = _delegate, token = _token, message = _message, consumer = _consumer;

#pragma mark -

- (IBAction) close
{
	@try {
		[_delegate tweetComposeViewControllerDidCancel: self];
	} @catch (NSException* exception) {
		NSLog(@"TweetComposeViewController caught an unexpected exception while calling the delegate: %@", exception);
	}
}

- (IBAction) send
{
	if ([_textView.text length] > 140)
	{
		UIAlertView* alertView = [[UIAlertView alloc] initWithTitle: @"The tweet is too long" message: @"Twitter messages can only be up to 140 characters long." delegate: nil
			cancelButtonTitle: @"OK" otherButtonTitles: nil];
		if (alertView != nil) {
			[alertView show];
			[alertView release];
		}
	}
	else
	{
		_tweetPoster = [TwitterTweetPoster new];
		if (_tweetPoster != nil) {
			_tweetPoster.consumer = _consumer;
			_tweetPoster.token = _token;
			_tweetPoster.delegate = self;
			_tweetPoster.message = _textView.text;
			[_tweetPoster execute];
		}

//		@try {
//			[_delegate tweetComposeViewController: self didFinishWithResult: 1 error: nil];
//		} @catch (NSException* exception) {
//			NSLog(@"TweetComposeViewController caught an unexpected exception while calling the delegate: %@", exception);
//		}
	}
}

#pragma mark -

- (void) updateCharactersLeftLabel
{
	NSInteger count = 140 - [_textView.text length];

	if (count < 0) {
		_charactersLeftLabel.textColor = [UIColor redColor];
	} else {
		_charactersLeftLabel.textColor = [UIColor grayColor];
	}

	_charactersLeftLabel.text = [NSString stringWithFormat: @"%d", count];
}

#pragma mark -

- (void) viewDidLoad
{
	_textView.text = _message;
	_textView.delegate = self;
	
	[self updateCharactersLeftLabel];
	
//	// Check if the user was previously authenticated
//	
//	NSString* authenticationToken = [_tweetComposeDelegate authenticationTokenForTweetComposeViewController: self];
//	if (authenticationToken == nil) {
//		[self setupLoginScreen];
//	}
}

- (void) viewWillAppear: (BOOL) animated
{
	[_textView becomeFirstResponder];
}

#pragma mark -

- (void) textViewDidChange: (UITextView*) textView
{
	[self updateCharactersLeftLabel];
}

#pragma mark -

- (void) twitterTweetPosterDidSucceed: (TwitterTweetPoster*) twitterTweetPoster
{
	[_delegate tweetComposeViewControllerDidSucceed: self];
}

- (void) twitterTweetPoster: (TwitterTweetPoster*) twitterTweetPoster didFailWithError: (NSError*) error
{
	[_delegate tweetComposeViewController: self didFailWithError: error];
}

@end