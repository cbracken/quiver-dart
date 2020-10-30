// Copyright 2013 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// @dart = 2.9

library quiver.async.iteration_test;

import 'dart:async';

import 'package:quiver/src/async/iteration.dart';
import 'package:test/test.dart';

void main() {
  group('reduceAsync', () {
    test('should reduce iterable', () {
      var items = [];
      return reduceAsync([1, 2, 3], 0, (v, e) {
        items.add(e);
        return Future(() => v + e);
      }).then((r) {
        expect(items, [1, 2, 3]);
        expect(r, 6);
      });
    });
  });

  group('forEachAsync', () {
    test('should schedule one outstanding task by default', () {
      int pending = 0;
      var results = [];
      return forEachAsync([1, 2, 3], (i) {
        pending++;
        if (pending > 1) fail('too many pending tasks');
        results.add(i);
        return Future(() {
          pending--;
        });
      }).then((_) {
        expect(results, [1, 2, 3]);
      });
    });

    test('should schedule maxTasks tasks', () {
      int pending = 0;
      int maxPending = 0;
      var results = [];
      return forEachAsync([1, 2, 3, 4], (i) {
        pending++;
        if (pending > 3) fail('too many pending tasks');
        if (pending > maxPending) maxPending = pending;
        results.add(i);
        return Future(() {
          pending--;
        });
      }, maxTasks: 3)
          .then((_) {
        expect(results, [1, 2, 3, 4]);
        expect(maxPending, 3);
      });
    });

    test('should validate maxTasks', () {
      expect(() => forEachAsync([], (i) => null, maxTasks: null),
          throwsArgumentError);
      expect(() => forEachAsync([], (i) => null, maxTasks: 0),
          throwsArgumentError);
    });

    test('should validate iterable', () {
      expect(() => forEachAsync(null, (i) => null), throwsArgumentError);
    });

    test('should complete when given no work', () {
      return forEachAsync([], (i) => null);
    });
  });
}
